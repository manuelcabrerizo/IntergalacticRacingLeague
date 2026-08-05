extends Node

enum GameplayOption
{
	SINGLE_PLAYER,
	SPLIT_SCREEN
}

enum GameModeOption
{
	RACE,
	SURVIVAL
}

var main_menu_path: String = "res://Scenes/MainMenu.tscn"
var level_selector_path: String = "res://Scenes/LevelSelector.tscn"
var game_mode_selector_path: String = "res://Scenes/GameModeSelector.tscn"

var current_level: PackedScene = null
var current_level_lap_count: int = 0
var current_gameplay_option: GameplayOption = GameplayOption.SINGLE_PLAYER
var current_game_mode: GameModeOption = GameModeOption.RACE
