extends Control

@onready var gameplay_info: Control = $GameplayInfo
@onready var count_down_text: Label = $GameplayInfo/CountDownText
@onready var race_time_text: Label = $GameplayInfo/RaceTimeText
@onready var race_lap_text: Label = $GameplayInfo/RaceLapText
@onready var position_text: Label = $GameplayInfo/HBoxContainer/PositionText
@onready var ships_count_text: Label = $GameplayInfo/HBoxContainer/ShipsCountText
@onready var power_up_icon: NinePatchRect = $GameplayInfo/PowerUpIcon
@onready var power_up_texture: TextureRect = $GameplayInfo/PowerUpIcon/PowerUpTexture

@onready var result_info: Control = $ResultInfo
@onready var end_title_text: Label = $ResultInfo/EndTitleText
@onready var end_position_text: Label = $ResultInfo/EndPositionText

@onready var elimination_info: Control = $EliminationInfo
@onready var elimination_text: Label = $EliminationInfo/EliminationText
@onready var elimination_count_down: Label = $EliminationInfo/EliminationCountDown

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var player_position: int = 0
@export var player_id: int = 1
@export var pickup_data: PickupData
@export var beep: AudioStream
@export var final_beep: AudioStream

func _ready() -> void:
	EventBuss.count_down_timer_change.connect(on_count_down_timer_change)
	EventBuss.race_state_chane_.connect(on_race_state_change)
	EventBuss.race_timer_change.connect(on_race_timer_change)
	EventBuss.player_change_position.connect(on_player_position_change)
	EventBuss.player_start_new_lap.connect(on_player_start_new_lap)
	EventBuss.slow_down_pickup_grabbed.connect(on_slow_down_pickup_grabbed)
	EventBuss.slow_down_pickup_used.connect(on_slow_down_pickup_used)
	EventBuss.elimination_count_down_start.connect(on_elimination_count_down_start)
	EventBuss.elimination_count_down_end.connect(on_elimination_count_down_end)
	EventBuss.elimination_count_down_change.connect(on_elimination_count_down_change)
	EventBuss.ships_remaining_change.connect(on_ships_remaining_change)
	power_up_icon.visible = false
	gameplay_info.visible = true
	result_info.visible = false
	elimination_info.visible = false
	pass

func on_count_down_timer_change(value: int):
	count_down_text.text = str(value)
	pass

func on_race_state_change(state: int, reason: int, id_mask: int):
	if (id_mask & (1 << player_id)) == 0:
		return
	match (state):
		Gameplay.RaceState.COUNT_DOWN:
			count_down_text.visible = true
		Gameplay.RaceState.IN_PROGRESS:
			race_end(reason)
			count_down_text.visible = false
		Gameplay.RaceState.ENDED:
			race_end(reason)
	pass
	
func on_race_timer_change(value: int):
	var minutes: int = int(floorf(value/60.0))
	var secionds: int = int(fmod(value, 60.0))
	race_time_text.text = str(minutes) + ":" + str(secionds)
	pass

func on_player_position_change(pos: int, id: int):
	if id != player_id:
		return
	player_position = pos
	position_text.text = "P" + str(pos)
	pass
	
func on_player_start_new_lap(lap: int, id: int):
	if id != player_id:
		return
	if GameState.current_game_mode == GameState.GameModeOption.RACE:
		race_lap_text.text = "Lap " + str(lap) + " of " + str(GameState.current_level_lap_count)
	else:
		race_lap_text.text = "Lap " + str(lap)
	pass
	
func on_slow_down_pickup_grabbed(id: int, pick_up_type: SlowDownPickup.SlowDownPickupType):
	if id != player_id:
		return
	power_up_texture.texture = pickup_data.pickups[pick_up_type]
	power_up_icon.visible = true
	pass
	
func on_slow_down_pickup_used(id: int):
	if id != player_id:
		return
	power_up_icon.visible = false
	pass
	
func race_end(reason: int):
	match(reason):
		Gameplay.RaceStateChangeReason.PLAYER_FINISH:
			process_end_screen("Finish", "P" + str(player_position), Color.PALE_GREEN)
		Gameplay.RaceStateChangeReason.TIME_OUT:
			process_end_screen("Timeout", "GO Faster!", Color.INDIAN_RED)
		Gameplay.RaceStateChangeReason.ELIMINATED:
			process_end_screen("Eliminated", "GO Faster!", Color.INDIAN_RED)
	pass
	
func process_end_screen(title: String, desc: String, color: Color):
	end_title_text.text = title
	end_title_text.label_settings.font_color = color
	end_position_text.text = desc
	end_position_text.label_settings.font_size = 64
	result_info.visible = true
	gameplay_info.visible = false
	if EventBuss.elimination_count_down_start.is_connected(on_elimination_count_down_start):
		EventBuss.elimination_count_down_start.disconnect(on_elimination_count_down_start)
	if EventBuss.elimination_count_down_end.is_connected(on_elimination_count_down_end):
		EventBuss.elimination_count_down_end.disconnect(on_elimination_count_down_end)
	if EventBuss.elimination_count_down_change.is_connected(on_elimination_count_down_change):
		EventBuss.elimination_count_down_change.disconnect(on_elimination_count_down_change)
	pass
	
func on_elimination_count_down_start(value: int):
	elimination_info.visible = true
	elimination_count_down.text = str(value)
	pass
	
func on_elimination_count_down_end():
	audio_stream_player.stream = final_beep
	audio_stream_player.play()
	elimination_info.visible = false
	pass
	
func on_elimination_count_down_change(value: int):
	if value >= 1 and value <= 3:
		elimination_count_down.text = str(value)
		audio_stream_player.stream = beep
		audio_stream_player.play()
	pass
	
func on_ships_remaining_change(ships_remaining: int):
	ships_count_text.text = " of " + str(ships_remaining)
	pass
