extends Control

@export var level_selector_data: LevelSelectorData

@onready var level_left_button: Level = $LevelLeftButton
@onready var leve_center_button: Level = $LeveCenterButton
@onready var level_right_button: Level = $LevelRightButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var loading_screen: NinePatchRect = $LoadingScreen
@onready var progress_bar: ProgressBar = $LoadingScreen/ProgressBar


var current_levels: Array
var current_level: int = 0

var loading_level: bool = false
var loading_level_path: String = ""

func _ready() -> void:
	loading_screen.visible = false
	loading_level = false
	
	if GameState.current_gameplay_option == GameState.GameplayOption.SPLIT_SCREEN:
		current_levels = level_selector_data.two_player_levels;
	elif GameState.current_gameplay_option == GameState.GameplayOption.SINGLE_PLAYER:
		current_levels = level_selector_data.levels
	
	update_level_info(level_left_button, (current_level - 1) % current_levels.size())
	update_level_info(leve_center_button, current_level)
	update_level_info(level_right_button, (current_level + 1) % current_levels.size())
	pass
	
func _on_left_button_button_down() -> void:
	audio_stream_player.play()
	current_level = (current_level - 1) % current_levels.size()
	update_level_info(level_left_button, (current_level - 1) % current_levels.size())
	update_level_info(leve_center_button, current_level)
	update_level_info(level_right_button, (current_level + 1) % current_levels.size())
	pass
	
func _on_right_button_button_down() -> void:
	audio_stream_player.play()
	current_level = (current_level + 1) % current_levels.size()
	update_level_info(level_left_button, (current_level - 1) % current_levels.size())
	update_level_info(leve_center_button, current_level)
	update_level_info(level_right_button, (current_level + 1) % current_levels.size())
	pass
	
func update_level_info(level, index):
	var level_data: LevelData = current_levels[index]
	level.level_title.text = level_data.title
	level.level_texture.texture = level_data.level_texture
	pass

func _on_select_button_button_down() -> void:
	var level_data: LevelData = current_levels[current_level]
	load_level(level_data.level_to_load)
	pass
	
func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file(GameState.game_mode_selector_path)
	pass
	
func load_level(level_to_load: String):
	loading_level_path = level_to_load
	ResourceLoader.load_threaded_request(loading_level_path)
	loading_level = true
	loading_screen.visible = true
	pass
	
func _process(_delta: float) -> void:
	if loading_level:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(loading_level_path, progress)
		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100
			pass
		elif status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			GameState.current_level = ResourceLoader.load_threaded_get(loading_level_path)
			get_tree().change_scene_to_packed(GameState.current_level)
			pass
	pass
	
