extends HBoxContainer

@onready var minutes_label: Label = $MinutesLabel
@onready var seconds_label: Label = $SecondsLabel
@onready var milliseconds_label: Label = $MillisecondsLabel

var time: float
var minutes: int
var seconds: int
var milliseconds: int
var is_running: bool


func _process(delta: float) -> void:
	if not is_running:
		return

	time += delta
	milliseconds = fmod(time, 1) * 100
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60

	minutes_label.text = "%02d:" % minutes
	seconds_label.text = "%02d." % seconds
	milliseconds_label.text = "%03d" % milliseconds


func start_timer() -> void:
	is_running = true


func stop_timer() -> void:
	is_running = false
