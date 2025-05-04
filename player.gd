extends RigidBody3D


## How much vertical force to apply when moving
@export_range(75.0, 3_000.0) var thrust: float = 1_000.0

## How much rotation force to apply while moving
@export var torque: float = 100.0


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)

	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque * delta))
	elif Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque * delta))


func _on_body_entered(body: Node) -> void:
	if "Goal" in body.get_groups():
		print("You've won!")
		complete_level()
	elif "Start" in body.get_groups():
		print("Starting position set!")
	elif "Hazard" in body.get_groups():
		crash_sequence()


func crash_sequence() -> void:
	get_tree().call_deferred("reload_current_scene")
	get_tree().quit()



func complete_level() -> void:
	get_tree().quit()
