extends Control

@export var duration: float = 4
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.one_shot = true
	timer.wait_time = duration
	timer.start()
	pass

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	pass
