class_name Ship
extends CharacterBody3D

var slow_down_mine_scene : PackedScene = preload("res://Objects/SlowDownMine.tscn")

const TRACK_PULL: float = 128.0*1.5
const TRACK_PUSH: float = 2000.0
const ROTATION_YAW_SPEED: float = 0.075
const ROTATION_ROLL_SPEED: float = 2.0
const ROTATION_DAMPING: float = 0.05
const THRUST_ACC: float = 2000.0
const THRUST_DEACC: float = 2500.0
const THRUST_MAX: float = 4000.0
const MASS: float = 1.0
const MAX_VELOCITY: float = 250.0
const END_VELOCITY: float = 125.0

var acc: Vector3 = Vector3.ZERO
var thrust: Vector3 = Vector3.ZERO
var damping: float = 0.8
var vel_yaw: float = 0
var vel_roll: float = 0
var thrust_mag: float = 0.0
var hit_normal: Vector3
var height: float

var force: Vector3 = Vector3.ZERO

var max_velocity: float = MAX_VELOCITY

var can_move: bool = false
var is_ended: bool = false;

var is_out_of_bounce: bool = false
var reset_transform: Transform3D

var current_lap_offset: float = 0.0
var last_lap_offset: float = 0
var track_offset: float = 0.0

var current_lap: int = 0
var max_lap: int = 0;
var current_position: int = -1
var can_spawn_slow_down_mine: bool = false

var first_update: bool = true

func  _ready() -> void:
	EventBuss.race_state_chane.connect(on_race_state_change)
	EventBuss.on_ship_spawn(self)
	pass
	
func on_race_state_change(state: int, _reason: int):
	match(state):
		Gameplay.RaceState.COUNT_DOWN:
			can_move = false
		Gameplay.RaceState.IN_PROGRESS:
			can_move = true
		Gameplay.RaceState.ENDED:
			is_ended = true
			max_velocity = END_VELOCITY
	pass

func ship_update(delta: float, track_path: Path3D, track_path_follow: PathFollow3D) -> void:
	process_turns(delta)
	process_height_and_hit_normal(track_path, track_path_follow)
	var forward: Vector3 = process_alignemt_with_track(delta)
	process_thrust(forward, delta)
	add_forces_and_integrate_velocity(forward, delta)
	move_and_slide()
	process_laps_and_position(track_path, track_path_follow)
	pass

func ship_reset(track_path: Path3D):
	position = reset_transform.origin + reset_transform.basis.y * 5.0
	last_lap_offset = get_offset_on_path(track_path)/track_path.curve.get_baked_length()
	current_lap_offset = last_lap_offset
	is_out_of_bounce = false
	thrust_mag = 0.0
	velocity = Vector3.ZERO
	rotation = reset_transform.basis.get_euler()
	pass

func process_turns(delta: float):
	global_rotate(basis.y, vel_yaw)
	vel_yaw *= pow(ROTATION_DAMPING, delta)
	vel_roll *= pow(ROTATION_DAMPING, delta)
	pass
	
func process_height_and_hit_normal(track_path: Path3D, track_path_follow: PathFollow3D):
	hit_normal = Vector3.UP
	height = 100.0
	var space_state = get_world_3d().direct_space_state
	var origin = position
	var end = origin -basis.y * 100.0
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 1 << 1
	var result = space_state.intersect_ray(query)
	if !result.is_empty():
		hit_normal = result["normal"]
		var to_hit_position: Vector3 = position - result["position"]
		height = to_hit_position.dot(hit_normal)
	elif not is_out_of_bounce:
		reset_transform = get_closest_transform_on_path(position, track_path, track_path_follow)
		is_out_of_bounce = true
	pass

func process_alignemt_with_track(delta: float) -> Vector3:
	var forward = basis.z.normalized()
	var up = hit_normal.normalized()
	var right = up.cross(forward).normalized()
	forward = right.cross(up).normalized()
	var target_basis = Basis(right, up, forward)
	var current_quat = global_transform.basis.get_rotation_quaternion()
	var target_quat = target_basis.get_rotation_quaternion()
	var new_quat = current_quat.slerp(target_quat, (20.0/height)*delta).normalized()
	global_transform.basis = Basis(new_quat)
	return -forward

func process_thrust(forward: Vector3, delta: float):
	if thrust_mag > THRUST_MAX:
		thrust_mag = THRUST_MAX
	elif thrust_mag < 0.0:
		thrust_mag = 0.0
	thrust = forward * (thrust_mag * delta)
	pass
	
func add_forces_and_integrate_velocity(forward: Vector3, delta: float):
	# add thurst force
	force += thrust
	# add track attraction force
	force += -hit_normal * TRACK_PULL;
	# add track repusion force
	force += hit_normal * TRACK_PUSH / height;
	var nose_velocity: Vector3 = forward * velocity.length()
	acc = nose_velocity - velocity
	acc += force / MASS
	velocity += acc * delta
	velocity *= pow(damping, delta)
	if velocity.length_squared() > max_velocity*max_velocity:
		velocity = velocity.normalized() * max_velocity
	# clear forces
	force = Vector3.ZERO
	pass
	
func process_laps_and_position(track_path: Path3D, track_path_follow: PathFollow3D):
	if first_update:
		last_lap_offset = get_offset_on_path(track_path)/track_path.curve.get_baked_length()
		first_update = false
	else:
		last_lap_offset = current_lap_offset
	current_lap_offset = get_offset_on_path(track_path)/track_path.curve.get_baked_length()
	if absf(current_lap_offset - last_lap_offset) > 0.8:
		if is_going_forward(track_path, track_path_follow):
			start_new_lap()
		else:
			current_lap = current_lap - 1
	track_offset = current_lap + current_lap_offset
	pass
	
func get_closest_transform_on_path(world_pos: Vector3, track_path: Path3D, track_path_follow: PathFollow3D) -> Transform3D:
	var local_pos = track_path.to_local(world_pos)
	var closest_offset = track_path.curve.get_closest_offset(local_pos)
	track_path_follow.progress = closest_offset
	return track_path_follow.global_transform
	
func get_offset_on_path(track_path: Path3D) -> float:
	var local_pos = track_path.to_local(position)
	return track_path.curve.get_closest_offset(local_pos)
	
func start_new_lap():
	current_lap = current_lap + 1
	max_lap = max(max_lap, current_lap)
	pass
	
	
func set_current_position(pos: int):
	current_position = pos
	pass
	
func is_going_forward(track_path: Path3D, track_path_follow: PathFollow3D) -> bool:
	var closest_transform: Transform3D = get_closest_transform_on_path(position, track_path, track_path_follow)
	var dir: bool = basis.z.dot(closest_transform.basis.z) > 0
	var vel: bool = velocity.dot(-closest_transform.basis.z) > 0
	return dir and vel
	
func process_auto_pilot(delta: float, track_path: Path3D, track_path_follow: PathFollow3D, track_generator: Node3D):
	var path_closes_trasform: Transform3D = get_closest_transform_on_path(position, track_path, track_path_follow)
	# calculate align ratio
	var path_turn_direction: Vector3 = path_closes_trasform.basis.z
	var h: float = basis.y.dot(path_turn_direction)
	path_turn_direction -= basis.y * h
	path_turn_direction = path_turn_direction.normalized()
	var direction_turn_ratio: float = basis.z.signed_angle_to(path_turn_direction, basis.y)
	var align_ration = direction_turn_ratio*7.0
	# calculate turn ratio
	var to_path: Vector3 = (path_closes_trasform.origin - position)
	var t = -path_closes_trasform.basis.x.dot(to_path) / (track_generator.width*0.5)
	var local_velocity = global_transform.basis.inverse() * velocity
	var velocity_z = -local_velocity.z / 200.0
	var turn_ration: float  = 0.0
	if t <= -0.15 or t >= 0.15:
		turn_ration = (t*7.0) * velocity_z;
	#integrate thrust and turn velocity
	thrust_mag += THRUST_ACC * delta
	vel_yaw += ROTATION_YAW_SPEED * align_ration * delta
	vel_roll += ROTATION_ROLL_SPEED * align_ration * delta
	vel_yaw += ROTATION_YAW_SPEED * turn_ration * delta
	vel_roll += ROTATION_ROLL_SPEED * turn_ration * delta
	pass

func slow_down_mine_grabbed():
	can_spawn_slow_down_mine = true
	pass

func spawn_slow_down_mine():
	if not can_spawn_slow_down_mine:
		return
	var slow_down_mine: SlowDownMine = slow_down_mine_scene.instantiate()
	get_tree().root.add_child(slow_down_mine)
	slow_down_mine.set_instigator(self)
	slow_down_mine.position = position - (basis.y * height)
	can_spawn_slow_down_mine = false
	pass
