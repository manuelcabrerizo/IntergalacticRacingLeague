class_name Gameplay
extends Node3D

enum RaceState
{
	NONE,
	COUNT_DOWN,
	IN_PROGRESS,
	ENDED
}

enum RaceStateChangeReason 
{
	NORMAL,
	TIME_OUT,
	PLAYER_FINISH,
	ELIMINATED,
}

@export var sound_data: SoundData
@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"

@export var count_down_duration: int = 4
var count_down_time: int = 0

@export var race_lap_count: int = 10
@export var race_duration: int = 60 * 5
var race_time: int = 0

var state: RaceState = RaceState.NONE
var game_mode: GameMode = null
var ships: Array[Ship]
var players: Array[Player]

func _init() -> void:
	EventBuss.ship_spawn.connect(on_ship_spawn)
	match GameState.current_game_mode:
		GameState.GameModeOption.RACE:
			game_mode = RaceGameMode.new()
		GameState.GameModeOption.SURVIVAL:
			game_mode = SurvivalGameMode.new()
	game_mode.init(self)
	pass

func _ready() -> void:
	game_mode.ready()
	pass
	
func _exit_tree():
	game_mode.free()
	pass

func _process(_delta: float) -> void:
	game_mode.update()
	pass
	
func on_ship_spawn(ship: Ship):
	ships.push_back(ship)
	if ship is Player:
		players.push_back(ship)
	pass
	
func set_state(new_state: RaceState, reason: RaceStateChangeReason, id_mask: int):
	state = new_state
	EventBuss.on_race_state_change(new_state, reason, id_mask)
	pass
	
func get_player_from_id(id: int) -> Player:
	for p in players:
		if p.id == id:
			return p
	return null
