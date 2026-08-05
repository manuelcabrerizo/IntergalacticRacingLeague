class_name SlowDownProjectile
extends Node3D

const PROJECTILE_HEIGHT: int = 10

@onready var timer: Timer = $Timer
@onready var explotion_stream_player_3d: AudioStreamPlayer3D = $ExplotionStreamPlayer3D
@onready var explotion_stream_player_split_screen: AudioStreamPlayer = $ExplotionStreamPlayerSplitScreen
@onready var fire_stream_player_3d: AudioStreamPlayer3D = $FireStreamPlayer3D
@onready var fire_stream_player_split_screen: AudioStreamPlayer = $FireStreamPlayerSplitScreen
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D
@onready var explosion_particles: CPUParticles3D = $ExplosionParticles

@export var speed: float = 300.0
@export var slow_down_time: float = 1.0

var is_initialize: bool = false
var instigator: Ship = null
var target: Ship = null
var track_path: Path3D = null
var track_path_follow: PathFollow3D = null
var is_hit: bool = false

func _ready() -> void:
	timer.one_shot = true
	timer.wait_time = slow_down_time
	timer.timeout.connect(on_detroy)
	explosion_particles.emitting = false
	pass

func initialize(new_instigator: Ship, new_track_path: Path3D, new_track_path_follow: PathFollow3D):
	instigator = new_instigator
	track_path = new_track_path
	track_path_follow = new_track_path_follow
	position = instigator.position
	is_initialize = true
	play_fire_sound()
	pass
	
func _process(delta: float) -> void:
	if !is_initialize:
		return
	if is_hit:
		return
	if target == null:
		follow_track(delta)
	else:
		follow_target(delta)
	pass
	
func follow_track(delta: float):
	var path_closes_trasform: Transform3D = get_closest_transform_on_path(position)
	var new_quat = path_closes_trasform.basis.get_rotation_quaternion()
	global_transform.basis = Basis(new_quat)
	position = position - basis.z * (speed * delta)
	var to_origin: Vector3 = position - path_closes_trasform.origin
	var projection = to_origin.dot(path_closes_trasform.basis.y)
	var closes_point_on_plane = position - (path_closes_trasform.basis.y * projection)
	position = closes_point_on_plane + (path_closes_trasform.basis.y * PROJECTILE_HEIGHT)
	pass
	
func follow_target(delta: float):
	var to_target: Vector3 = target.position - position
	var forward: Vector3 = to_target.normalized()
	var up: Vector3 = Vector3.UP
	var right: Vector3 = up.cross(forward).normalized()
	up = right.cross(forward).normalized()
	var target_basis = Basis(right, up, forward)
	var target_quat = target_basis.get_rotation_quaternion().normalized()
	global_transform.basis = Basis(target_quat)
	position = position + forward * (speed*delta)
	pass
	
func get_closest_transform_on_path(world_pos: Vector3) -> Transform3D:
	var local_pos = track_path.to_local(world_pos)
	var closest_offset = track_path.curve.get_closest_offset(local_pos)
	track_path_follow.progress = closest_offset
	return track_path_follow.global_transform

func _on_range_body_entered(body: Node3D) -> void:
	var ship = body as Ship
	if instigator == ship:
		return
	if target != null:
		return
	var to_ship: Vector3 = ship.position - position
	var projection = (-basis.z).dot(to_ship)
	if projection >= 0.8:
		target = ship
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Ship:
		var ship = body as Ship
		if instigator == ship:
			return
		if is_hit:
			return
			
		target = ship
		play_explotion_sound()
		target.velocity = Vector3.ZERO
		target.damping = 0.001
		timer.start()
		is_hit = true
		cpu_particles_3d.emitting = false
		explosion_particles.emitting = true
	pass

func play_fire_sound():
	if GameState.current_gameplay_option == GameState.GameplayOption.SINGLE_PLAYER: 
		fire_stream_player_3d.play()
	elif GameState.current_gameplay_option == GameState.GameplayOption.SPLIT_SCREEN:
		if instigator is Player:
			fire_stream_player_split_screen.play()
	pass

func play_explotion_sound():
	if GameState.current_gameplay_option == GameState.GameplayOption.SINGLE_PLAYER: 
		explotion_stream_player_3d.play()
	elif GameState.current_gameplay_option == GameState.GameplayOption.SPLIT_SCREEN:
		if instigator is Player or target is Player:
			explotion_stream_player_split_screen.play()
	pass

func on_detroy():
	if target != null:
		target.damping = 0.8
	queue_free()
	pass

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent_node_3d() is SlowDownMine:
		queue_free()
	pass
