extends Node

signal pause_game(paused: bool)
signal race_state_chane(state: int, reason: int)
signal count_down_timer_change(value: int)
signal race_timer_change(value: int)
signal ship_spawn(ship: Ship)
signal player_start_new_lap(lap: int)
signal player_change_position(pos: int)
signal setting_back_button_clicked
signal slow_down_pickup_grabbed
signal slow_down_pickup_used

func on_pause_game(paused: bool):
	pause_game.emit(paused)
	pass

func on_race_state_change(state: int, reason: int):
	race_state_chane.emit(state, reason)
	pass
	
func on_count_down_timer_change(value: int):
	count_down_timer_change.emit(value)
	pass
	
func on_race_timer_change(value: int):
	race_timer_change.emit(value)
	pass
	
func on_ship_spawn(ship: Ship):
	ship_spawn.emit(ship)
	pass
	
func on_player_start_new_lap(lap: int):
	player_start_new_lap.emit(lap)
	pass

func on_player_change_position(pos: int):
	player_change_position.emit(pos)
	pass
	
func on_setting_back_button_clicked():
	setting_back_button_clicked.emit()
	pass
	
func on_slow_down_pickup_grabbed():
	slow_down_pickup_grabbed.emit()
	pass
	
func on_slow_down_pickup_used():
	slow_down_pickup_used.emit()
	pass
