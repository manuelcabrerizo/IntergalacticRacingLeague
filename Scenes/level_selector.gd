extends Control

@export var level_selector_data: LevelSelectorData

@onready var level_left_button: Level = $LevelLeftButton
@onready var leve_center_button: Level = $LeveCenterButton
@onready var level_right_button: Level = $LevelRightButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var current_level: int = 0

func _ready() -> void:
	update_level_info(level_left_button, (current_level - 1) % level_selector_data.levels.size())
	update_level_info(leve_center_button, current_level)
	update_level_info(level_right_button, (current_level + 1) % level_selector_data.levels.size())
	pass

func _on_left_button_button_down() -> void:
	audio_stream_player.play()
	current_level = (current_level - 1) % level_selector_data.levels.size()
	update_level_info(level_left_button, (current_level - 1) % level_selector_data.levels.size())
	update_level_info(leve_center_button, current_level)
	update_level_info(level_right_button, (current_level + 1) % level_selector_data.levels.size())
	pass


func _on_right_button_button_down() -> void:
	audio_stream_player.play()
	current_level = (current_level + 1) % level_selector_data.levels.size()
	update_level_info(level_left_button, (current_level - 1) % level_selector_data.levels.size())
	update_level_info(leve_center_button, current_level)
	update_level_info(level_right_button, (current_level + 1) % level_selector_data.levels.size())
	pass
	
func update_level_info(level, index):
	var level_data: LevelData = level_selector_data.levels[index]
	level.level_title.text = level_data.title
	level.level_texture.texture = level_data.level_texture
	pass

func _on_select_button_button_down() -> void:
	var level_data: LevelData = level_selector_data.levels[current_level]
	GameState.current_level = load(level_data.level_to_load) 
	get_tree().change_scene_to_packed(GameState.current_level)
	pass


func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file(GameState.main_menu_path)
	pass
