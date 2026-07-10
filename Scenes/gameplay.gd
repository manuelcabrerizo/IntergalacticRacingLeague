class_name Gameplay
extends Node3D

enum RaceState {
	NONE,
	COUNT_DOWN,
	IN_PROGRESS,
	ENDED
}

enum RaceStateChangeReason {
	NORMAL,
	TIME_OUT,
	PLAYER_FINISH
}

var timer: Timer

@export var sound_data: SoundData
@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"

@export var count_down_duration: int = 4
var count_down_time: int = 0

@export var race_lap_count: int = 10
@export var race_duration: int = 60 * 5
var race_time: int = 0

var state: RaceState = RaceState.NONE

var ships: Array[Ship]

func _init() -> void:
	EventBuss.ship_spawn.connect(on_ship_spawn)
	EventBuss.player_start_new_lap.connect(on_player_start_new_lap)
	pass

func _ready() -> void:
	GameState.current_level_lap_count = race_lap_count
	timer = Timer.new()
	add_child(timer)
	set_count_down_state()
	pass

func _process(_delta: float) -> void:
	if state == RaceState.IN_PROGRESS:
		ships.sort_custom(func(a, b): return b.track_offset < a.track_offset)
		for i in range(ships.size()):
			ships[i].set_current_position(i+1)
	pass
	
func set_state(new_state: RaceState, reason: RaceStateChangeReason):
	state = new_state
	EventBuss.on_race_state_change(new_state, reason)
	pass
	
func set_count_down_state():
	audio_stream_player.stop()
	audio_stream_player.stream = sound_data.songs["count_down"]
	audio_stream_player.play()
	set_state(RaceState.COUNT_DOWN, RaceStateChangeReason.NORMAL)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(on_count_down_change)
	EventBuss.on_count_down_timer_change(count_down_duration)
	timer.start()
	pass
	
func on_count_down_change():
	count_down_time = count_down_time + 1
	EventBuss.on_count_down_timer_change(count_down_duration - count_down_time)
	if count_down_time == count_down_duration:
		timer.stop()
		timer.timeout.disconnect(on_count_down_change)
		set_in_progress_state();
	pass
	
func set_in_progress_state():
	audio_stream_player.stop()
	audio_stream_player.stream = sound_data.songs["in_progress"]
	audio_stream_player.play()
	set_state(RaceState.IN_PROGRESS, RaceStateChangeReason.NORMAL)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(on_race_time_change)
	EventBuss.on_race_timer_change(race_duration)
	timer.start()
	pass
	
func on_race_time_change():
	race_time = race_time + 1
	EventBuss.on_race_timer_change(race_duration - race_time)
	if race_time == race_duration:
		set_ended_state(RaceStateChangeReason.TIME_OUT, "timeout")
	pass
	
func on_ship_spawn(ship: Ship):
	ships.push_back(ship)
	pass

func on_player_start_new_lap(lap: int):
	if lap > race_lap_count and state != RaceState.ENDED:
		set_ended_state(RaceStateChangeReason.PLAYER_FINISH, "finish")
	pass
	
func set_ended_state(reason: RaceStateChangeReason, song: String):
	audio_stream_player.stop()
	audio_stream_player.stream = sound_data.songs[song]
	audio_stream_player.play()
	timer.stop()
	timer.timeout.disconnect(on_race_time_change)
	set_state(RaceState.ENDED, reason)
	pass
