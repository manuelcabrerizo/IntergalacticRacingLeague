extends Control

# GameplayPanel
@onready var gameplay_panel: Control = $Canvas/GameplayPanel
@onready var count_down_text: Label = $Canvas/GameplayPanel/CountDownText
@onready var race_time_text: Label = $Canvas/GameplayPanel/RaceTimeText
@onready var race_lap_text: Label = $Canvas/GameplayPanel/RaceLapText
@onready var position_text: Label = $Canvas/GameplayPanel/PositionText
@onready var power_up_icon: NinePatchRect = $Canvas/GameplayPanel/PowerUpIcon
# EndRacePanel
@onready var end_race_panel: Control = $Canvas/EndRacePanel
@onready var title_text: Label = $Canvas/EndRacePanel/TitleText
@onready var end_position_text: Label = $Canvas/EndRacePanel/EndPositionText

# PausePanel
@onready var pause_panel: Control = $Canvas/PausePanel

var player_position: int = 0

func _ready() -> void:
	EventBuss.count_down_timer_change.connect(on_count_down_timer_change)
	EventBuss.pause_game.connect(on_pause_game)
	EventBuss.race_state_chane.connect(on_race_state_change)
	EventBuss.race_timer_change.connect(on_race_timer_change)
	EventBuss.player_change_position.connect(on_player_position_change)
	EventBuss.player_start_new_lap.connect(on_player_start_new_lap)
	EventBuss.slow_down_pickup_grabbed.connect(on_slow_down_pickup_grabbed)
	EventBuss.slow_down_pickup_used.connect(on_slow_down_pickup_used)
	
	gameplay_panel.visible = true
	end_race_panel.visible = false
	pass

func on_pause_game(paused: bool):
	pause_panel.visible = paused
	pass
	
func on_race_state_change(state: int, reason: int):
	match (state):
		Gameplay.RaceState.COUNT_DOWN:
			count_down_text.visible = true
			race_time_text.visible = false
		Gameplay.RaceState.IN_PROGRESS:
			count_down_text.visible = false
			race_time_text.visible = true
		Gameplay.RaceState.ENDED:
			race_end(reason)
			end_race_panel.visible = true
			gameplay_panel.visible = false
	pass
	
func on_count_down_timer_change(value: int):
	count_down_text.text = str(value)
	pass

	
func on_race_timer_change(value: int):
	var minutes: int = int(floorf(value/60.0))
	var secionds: int = int(fmod(value, 60.0))
	race_time_text.text = str(minutes) + ":" + str(secionds)
	pass
	
func on_player_start_new_lap(lap: int):
	race_lap_text.text = "Lap " + str(lap) + "/" + str(GameState.current_level_lap_count)
	pass
	
func on_player_position_change(pos: int):
	player_position = pos
	position_text.text = "P" + str(pos)
	pass

func _on_play_again_buton_button_down() -> void:
	get_tree().change_scene_to_packed(GameState.current_level)
	pass

func _on_main_menu_button_button_down() -> void:
	get_tree().change_scene_to_file(GameState.main_menu_path)
	pass
	
func race_end(reason: int):
	match(reason):
		Gameplay.RaceStateChangeReason.PLAYER_FINISH:
			title_text.text = "Finish"
			title_text.label_settings.font_color = Color.PALE_GREEN
			end_position_text.text = "P" + str(player_position)
		Gameplay.RaceStateChangeReason.TIME_OUT:
			title_text.text = "Timeout"
			title_text.label_settings.font_color = Color.INDIAN_RED
			end_position_text.text = "GO Faster!"
			end_position_text.label_settings.font_size = 64
	pass
	
func on_slow_down_pickup_grabbed():
	power_up_icon.visible = true
	pass
	
func on_slow_down_pickup_used():
	power_up_icon.visible = false
	pass
	
