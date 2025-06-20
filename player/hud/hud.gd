extends Control
class_name HUD

@onready var damage_bar: ProgressBar = $DamageBar
@onready var level_timer: HBoxContainer = $LevelTimer


func set_damage_percentage(value: float) -> void:
	damage_bar.value = value


func start_time() -> void:
	level_timer.start_timer()


func end_time() -> void:
	level_timer.stop_timer()


func get_time() -> float:
	return level_timer.time
