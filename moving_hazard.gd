extends AnimatableBody3D


@export var destination: Vector3
@export var duration: float = 1.0
@export var time_between_positions: float = 1.0


func _ready() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)

	tween.tween_property(self, "global_position", global_position + destination, duration)
	tween.tween_interval(time_between_positions)
	tween.tween_property(self, "global_position", global_position, duration)
	tween.tween_interval(time_between_positions)
