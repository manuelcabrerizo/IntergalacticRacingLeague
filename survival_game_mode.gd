class_name SurvivalGameMode
extends GameMode

var timer: Timer
var elimination_timer: Timer

var elimination_time: float = 20
var elimination_time_counter: int = 0
var players_eliminated: int = 0

func init(new_owner: Gameplay):
	super(new_owner)
	EventBuss.ship_start_new_lap.connect(on_ship_start_new_lap)
	pass
	
func ready():
	super()
	timer = Timer.new()
	owner.add_child(timer)
	elimination_timer = Timer.new()
	elimination_time_counter = int(elimination_time)
	owner.add_child(elimination_timer)
	pass
	
func update():
	super()
	if owner.state == Gameplay.RaceState.NONE:
		owner.race_duration = calculate_race_duration(owner.ships.size())
		EventBuss.on_race_timer_change(owner.race_duration)
		set_count_down_state()
	elif owner.state == Gameplay.RaceState.IN_PROGRESS:
		owner.ships.sort_custom(func(a, b): return b.track_offset < a.track_offset)
		for i in range(owner.ships.size()):
			owner.ships[i].set_current_position(i+1)
	pass
	
func calculate_race_duration(ships_count: int) -> int:
	var elimination_rounds: int = 0
	while(ships_count > 1):
		@warning_ignore("integer_division")
		ships_count = ships_count - (ships_count/2)
		elimination_rounds = elimination_rounds + 1
	return elimination_rounds * int(elimination_time)
	
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
	EventBuss.on_ships_remaining_change(owner.ships.size())
	EventBuss.on_race_timer_change(owner.race_duration)
	pass
	
func on_eliminate_ships():
	if owner.ships.is_empty():
		return
		
	@warning_ignore("integer_division")
	var ships_to_eliminate_count: int = owner.ships.size() / 2
	while(ships_to_eliminate_count > 0):
		var ship: Ship = owner.ships.back()
		ship.ship_end()
		if ship is Npc:
			ship.set_current_position(-1)
		elif ship is Player:
			var player: Player = ship as Player
			set_ended_state_by_time_out(player.id)
		owner.ships.pop_back()
		ships_to_eliminate_count = ships_to_eliminate_count - 1
		
	EventBuss.on_ships_remaining_change(owner.ships.size())
	if owner.ships.size() == 1:
		var ship: Ship = owner.ships.back()
		if ship is Player:
			var player: Player = ship as Player
			set_ended_state_by_player_finish(player.id)
	pass

	
func on_race_time_change():
	owner.race_time = owner.race_time + 1
	EventBuss.on_race_timer_change(owner.race_duration - owner.race_time)
	
	elimination_time_counter = elimination_time_counter - 1
	if elimination_time_counter <= 3:
		if elimination_time_counter == 3:
			EventBuss.on_elimination_count_down_start(elimination_time_counter)
		elif elimination_time_counter == 0:
			EventBuss.on_elimination_count_down_end()
			elimination_time_counter = int(elimination_time)
		EventBuss.on_elimination_count_down_change(elimination_time_counter)
	pass
	
func set_ended_state_by_time_out(id: int):
	players_eliminated = players_eliminated + 1
	if players_eliminated == owner.players.size():
		owner.audio_stream_player.stop()
		owner.audio_stream_player.stream = owner.sound_data.songs["timeout"]
		owner.audio_stream_player.play()
		owner.set_state(Gameplay.RaceState.ENDED, Gameplay.RaceStateChangeReason.ELIMINATED, -1)
		for ship in owner.ships:
			ship.ship_end()
	else:
		var id_mask = (1 << id)
		owner.set_state(Gameplay.RaceState.IN_PROGRESS, Gameplay.RaceStateChangeReason.ELIMINATED, id_mask)
	pass
	
func set_ended_state_by_player_finish(id: int):
	owner.audio_stream_player.stop()
	owner.audio_stream_player.stream = owner.sound_data.songs["finish"]
	owner.audio_stream_player.play()
	elimination_timer.stop()
	var id_mask = (1 << id)
	owner.set_state(Gameplay.RaceState.ENDED, Gameplay.RaceStateChangeReason.PLAYER_FINISH, id_mask)
	owner.get_player_from_id(id).ship_end()
	pass
	
func on_ship_start_new_lap(lap: int, ship: Ship):
	if lap == 1 and ship == owner.ships.back():
		start_timers()
		pass
	pass
	
func start_timers():
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(on_race_time_change)
	timer.start()
	elimination_timer.wait_time = elimination_time
	elimination_timer.one_shot = false
	elimination_timer.timeout.connect(on_eliminate_ships)
	elimination_timer.start()
	pass
