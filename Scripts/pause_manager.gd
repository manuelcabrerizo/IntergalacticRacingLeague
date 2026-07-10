class_name PauseManager
extends Node3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func _input(event):
	if event.is_action_pressed("Pause"):
		get_tree().paused = not get_tree().paused
		EventBuss.on_pause_game(get_tree().paused)
