extends Control
@onready var end_buttons: NinePatchRect = $Canvas/EndButtons
@onready var pause_panel: Control = $Canvas/PausePanel

func _ready() -> void:
	EventBuss.pause_game.connect(on_pause_game)
	EventBuss.race_state_chane_.connect(on_race_state_change)
	EventBuss.all_players_finish.connect(on_all_players_finish)
	end_buttons.visible = false
	pause_panel.visible = false
	pass
	
func on_race_state_change(state: int, _reason: int, _id_mask: int):
	match (state):
		Gameplay.RaceState.ENDED:
			end_buttons.visible = true
	pass
	
func on_all_players_finish():
	end_buttons.visible = true

func on_pause_game(paused: bool):
	pause_panel.visible = paused
	pass

func _on_play_again_button_button_down() -> void:
	get_tree().change_scene_to_packed.call_deferred(GameState.current_level)
	pass
	
func _on_main_menu_button_button_down() -> void:
	get_tree().change_scene_to_file.call_deferred(GameState.main_menu_path)
	pass
