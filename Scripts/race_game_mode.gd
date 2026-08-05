class_name RaceGameMode
extends GameMode

var timer: Timer
var player_finish: int = 0

func init(new_owner: Gameplay):
	super(new_owner)
	EventBuss.player_start_new_lap.connect(on_player_start_new_lap)
	pass
	
func ready():
	super()
	GameState.current_level_lap_count = owner.race_lap_count
	timer = Timer.new()
	owner.add_child(timer)
	pass
	
func update():
	super()
	if owner.state == Gameplay.RaceState.NONE:
		EventBuss.on_race_timer_change(owner.race_duration)
		set_count_down_state()
	elif owner.state == Gameplay.RaceState.IN_PROGRESS:
		owner.ships.sort_custom(func(a, b): return b.track_offset < a.track_offset)
		for i in range(owner.ships.size()):
			owner.ships[i].set_current_position(i+1)
	pass
		
func set_count_down_state():
	owner.audio_stream_player.stop()
	owner.audio_stream_player.stream = owner.sound_data.songs["count_down"]
	owner.audio_stream_player.play()
	owner.set_state(Gameplay.RaceState.COUNT_DOWN, Gameplay.RaceStateChangeReason.NORMAL, -1)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(on_count_down_change)
	EventBuss.on_count_down_timer_change(owner.count_down_duration)
	timer.start()
	pass
	
func on_count_down_change():
	owner.count_down_time = owner.count_down_time + 1
	EventBuss.on_count_down_timer_change(owner.count_down_duration - owner.count_down_time)
	if owner.count_down_time == owner.count_down_duration:
		timer.stop()
		timer.timeout.disconnect(on_count_down_change)
		set_in_progress_state();
	pass
	
func set_in_progress_state():
	owner.audio_stream_player.stop()
	owner.audio_stream_player.stream = owner.sound_data.songs["in_progress"]
	owner.audio_stream_player.play()
	owner.set_state(Gameplay.RaceState.IN_PROGRESS, Gameplay.RaceStateChangeReason.NORMAL, -1)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(on_race_time_change)
	EventBuss.on_race_timer_change(owner.race_duration)
	EventBuss.on_ships_remaining_change(owner.ships.size())
	timer.start()
	pass
	
func on_race_time_change():
	owner.race_time = owner.race_time + 1
	EventBuss.on_race_timer_change(owner.race_duration - owner.race_time)
	if owner.race_time == owner.race_duration:
		set_ended_state_by_time_out()
	pass
		
func on_player_start_new_lap(lap: int, id: int):
	if lap == (GameState.current_level_lap_count + 1) and !owner.get_player_from_id(id).is_ended:
		set_ended_state_by_player_finish(id)
	pass
	
func set_ended_state_by_player_finish(id: int):
	
	player_finish = player_finish + 1
	if player_finish == owner.players.size():
		all_players_finish()
		pass
	else:
		var id_mask = (1 << id)
		owner.set_state(Gameplay.RaceState.IN_PROGRESS, Gameplay.RaceStateChangeReason.PLAYER_FINISH, id_mask)
		owner.get_player_from_id(id).ship_end()
	pass
	
func set_ended_state_by_time_out():
	owner.audio_stream_player.stop()
	owner.audio_stream_player.stream = owner.sound_data.songs["timeout"]
	owner.audio_stream_player.play()
	timer.stop()
	timer.timeout.disconnect(on_race_time_change)
	var id_mask: int = 0
	for p in owner.players:
		id_mask = id_mask | ((0 if p.is_ended else 1) << p.id)
	owner.set_state(Gameplay.RaceState.ENDED, Gameplay.RaceStateChangeReason.TIME_OUT, id_mask)
	for ship in owner.ships:
		ship.ship_end()
		pass
	pass
	
func all_players_finish():
	owner.audio_stream_player.stop()
	owner.audio_stream_player.stream = owner.sound_data.songs["finish"]
	owner.audio_stream_player.play()
	timer.stop()
	timer.timeout.disconnect(on_race_time_change)
	for ship in owner.ships:
		ship.ship_end()
		pass
	EventBuss.on_all_players_finish()
	owner.set_state(Gameplay.RaceState.ENDED, Gameplay.RaceStateChangeReason.PLAYER_FINISH, -1)
	pass
