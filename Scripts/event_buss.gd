extends Node

signal pause_game(paused: bool)
signal setting_back_button_clicked
signal all_players_finish
signal race_state_chane_(state: int, reason: int, id: int)
signal count_down_timer_change(value: int)
signal race_timer_change(value: int)
signal ship_spawn(ship: Ship)
signal ship_start_new_lap(lap: int, ship: Ship)
signal player_start_new_lap(lap: int, id: int)
signal player_change_position(pos: int, id: int)
signal slow_down_pickup_grabbed(id: int, pick_up_type: SlowDownPickup.SlowDownPickupType)
signal slow_down_pickup_used(id: int)
signal elimination_count_down_start(value: int)
signal elimination_count_down_end
signal elimination_count_down_change(value: int)
signal ships_remaining_change(ships_remaining: int)

func on_pause_game(paused: bool):
	pause_game.emit(paused)
	pass

func on_all_players_finish():
	all_players_finish.emit()
	pass

func on_race_state_change(state: int, reason: int, id: int):
	race_state_chane_.emit(state, reason, id)
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
	
func on_ship_start_new_lap(lap: int, ship: Ship):
	ship_start_new_lap.emit(lap, ship)
	pass
	
func on_player_start_new_lap(lap: int, id: int):
	player_start_new_lap.emit(lap, id)
	pass

func on_player_change_position(pos: int, id: int):
	player_change_position.emit(pos, id)
	pass
	
func on_setting_back_button_clicked():
	setting_back_button_clicked.emit()
	pass
	
func on_slow_down_pickup_grabbed(id: int, pick_up_type: SlowDownPickup.SlowDownPickupType):
	slow_down_pickup_grabbed.emit(id, pick_up_type)
	pass
	
func on_slow_down_pickup_used(id: int):
	slow_down_pickup_used.emit(id)
	pass
	
func on_elimination_count_down_start(value: int):
	elimination_count_down_start.emit(value)
	pass
	
func on_elimination_count_down_end():
	elimination_count_down_end.emit()
	pass
	
func on_elimination_count_down_change(value: int):
	elimination_count_down_change.emit(value)
	pass
	
func on_ships_remaining_change(ships_remaining: int):
	ships_remaining_change.emit(ships_remaining)
	pass
