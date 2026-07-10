extends Control

@onready var canvas: CanvasLayer = $".."
var setting_scene : PackedScene = preload("res://Scenes/Settings.tscn")
var settings: Settings = null

func _ready() -> void:
	settings = setting_scene.instantiate()
	canvas.add_child.call_deferred(settings)
	settings.visible = false
	EventBuss.setting_back_button_clicked.connect(on_settings_back_button_button_down)
	EventBuss.pause_game.connect(on_pause_game)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pass

func _on_pause_resume_button_button_down() -> void:
	get_tree().paused = not get_tree().paused
	Engine.time_scale = 0.0 if get_tree().paused else 1.0
	EventBuss.on_pause_game(get_tree().paused)
	pass

func _on_pause_restart_button_button_down() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_packed(GameState.current_level)
	pass

func _on_pause_settings_button_button_down() -> void:
	settings.visible = true
	pass
	
func on_settings_back_button_button_down() -> void:
	settings.visible = false
	pass

func _on_pause_main_menu_button_button_down() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(GameState.main_menu_path)
	pass
	
func on_pause_game(paused: bool):
	if not paused:
		settings.visible = false
	pass
