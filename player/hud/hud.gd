extends Control
class_name HUD


@onready var damage_bar: ProgressBar = $DamageBar


func set_damage_percentage(value: float) -> void:
	damage_bar.value = value
