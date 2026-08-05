extends Control

func _on_race_button_button_down() -> void:
	GameState.current_game_mode = GameState.GameModeOption.RACE
	get_tree().change_scene_to_file(GameState.level_selector_path)
	pass

func _on_survival_button_button_down() -> void:
	GameState.current_game_mode = GameState.GameModeOption.SURVIVAL
	get_tree().change_scene_to_file(GameState.level_selector_path)
	pass

func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_file(GameState.main_menu_path)
	pass
