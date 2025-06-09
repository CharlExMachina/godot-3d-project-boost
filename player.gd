extends RigidBody3D


@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

## How much vertical force to apply when moving
@export_range(75.0, 3_000.0) var thrust: float = 1_000.0

## How much rotation force to apply while moving
@export var torque: float = 100.0

## Controls whether or not the player is in the process of changing scenes
var is_transitioning: bool = false


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
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


func _on_body_entered(body: Node) -> void:
	if is_transitioning:
		return

	if "Goal" in body.get_groups():
		complete_level(body.next_level_path)
	elif "Start" in body.get_groups():
		print("Starting position set!")
	elif "Hazard" in body.get_groups():
		crash_sequence()


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
