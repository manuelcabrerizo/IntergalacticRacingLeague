extends Control

var setting_scene : PackedScene = preload("res://Scenes/Settings.tscn")
var settings: Settings = null
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var exit_button: TextureButton = $CanvasLayer/TextureRect/ExitButton

func _ready() -> void:
	settings = setting_scene.instantiate()
	canvas_layer.add_child(settings)
	settings.visible = false
	exit_button.visible = OS.get_name() != "Web"
	EventBuss.setting_back_button_clicked.connect(on_settings_back_button_button_down)
	pass

func _on_play_button_button_down() -> void:
	GameState.current_gameplay_option = GameState.GameplayOption.SINGLE_PLAYER
	get_tree().change_scene_to_file(GameState.game_mode_selector_path)
	pass
	
func _on_split_screen_button_button_down() -> void:
	GameState.current_gameplay_option = GameState.GameplayOption.SPLIT_SCREEN
	get_tree().change_scene_to_file(GameState.game_mode_selector_path)
	pass

func _on_settings_button_button_down() -> void:
	settings.visible = true
	pass
	
func on_settings_back_button_button_down() -> void:
	settings.visible = false
	pass

func _on_exit_button_button_down() -> void:
	get_tree().quit()
	pass
