extends RigidBody3D


@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles
@onready var rocket_base: Node3D = $Body/rocket_baseB2
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var crash_sound: AudioStreamPlayer = $CrashSound
@onready var hud: Control = $HUD


## How much vertical force to apply when moving
@export_range(75.0, 3_000.0) var thrust: float = 1_000.0

## How much rotation force to apply while moving
@export var torque: float = 100.0

## The color that shows up when the player's rocket receives damage
@export var damage_color: Color = Color.INDIAN_RED

## How strong will the player bounce back if they get stuck on the floor
@export var floor_recovery_impulse_force: float = 600.0

## How short the recovery time will be in seconds when stuck on the floor
@export var floor_recovery_wait_time: float = 0.5

## Controls whether or not the player is in the process of changing scenes
var is_transitioning: bool = false

## Controls whether the player is recovering from crashing with an object
var is_in_recovery: bool = false

var damage_amount: float = 0.0
var velocity_in_frame: Vector3 = Vector3.ZERO
var should_update_velocity_in_frame: bool = true
var frame: float = 0.0
var default_recovery_time: float = 0.0


func _ready() -> void:
	default_recovery_time = recovery_timer.wait_time

	var base = rocket_base.get_node("tmpParent/rocket_baseB") as MeshInstance3D
	var yellow_surface = base.get_active_material(2)


func _process(delta: float) -> void:
	velocity_in_frame = linear_velocity


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("boost") and not is_in_recovery:
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true

		if not rocket_audio.playing:
			rocket_audio.play()
	else:
		booster_particles.emitting = false
		rocket_audio.stop()

	if Input.is_action_pressed("rotate_left") and not Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, torque * delta))

	if Input.is_action_pressed("rotate_right") and not Input.is_action_just_released("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, -torque * delta))

	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() > 0 and not is_in_recovery:
		should_update_velocity_in_frame = false
		var collision_object = state.get_contact_collider_object(0)
		var velocity_length_on_impact = velocity_in_frame.length_squared()

		if (collision_object as Node3D).is_in_group("Hazard"):
			push_player(state.get_contact_collider_position(0), velocity_length_on_impact)
			increase_damage_amount(ceil(velocity_length_on_impact * 0.03))


func push_player(collision_position: Vector3, force_multiplier: float = 0) -> void:
	crash_sound.play()
	is_in_recovery = true

	var direction = (global_position - collision_position).normalized()

	if force_multiplier > 0.001:
		apply_central_force(Vector3(direction.x, direction.y, 0.0) * force_multiplier)
	else:
		apply_central_force(Vector3.UP * floor_recovery_impulse_force)
		recovery_timer.wait_time = floor_recovery_wait_time
		recovery_timer.start()
		return

	recovery_timer.start()


func _on_body_entered(body: Node) -> void:
	if is_transitioning:
		return

	if "Goal" in body.get_groups():
		complete_level(body.next_level_path)
		hud.end_time()
	elif "Start" in body.get_groups():
		print("Starting position set!")


func increase_damage_amount(speed_on_impact: float) -> void:
	damage_amount += speed_on_impact

	if damage_amount >= 100:
		damage_amount = 100
		crash_sequence()

	hud.set_damage_percentage(damage_amount)



func crash_sequence() -> void:
	booster_particles.emitting = false
	rocket_audio.stop()

	explosion_particles.emitting = true
	explosion_audio.play()
	is_transitioning = true
	set_physics_process(false)
	var tween = create_tween()

	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)


func complete_level(next_level_file: String) -> void:
	success_particles.emitting = true
	success_audio.play()
	is_transitioning = true
	set_physics_process(false)
	var tween = create_tween()

	tween.tween_interval(1.0)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file)
	)


func _on_recovery_timer_timeout() -> void:
	is_in_recovery = false
	should_update_velocity_in_frame = true

	if (recovery_timer.wait_time != default_recovery_time):
		recovery_timer.wait_time = default_recovery_time


func _on_body_exited(body: Node) -> void:
	if "Start" in body.get_groups():
		hud.start_time()
