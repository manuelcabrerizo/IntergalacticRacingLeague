class_name Player
extends Ship

const MIN_ENGINE_PITCH: float = 0.5
const MAX_ENGINE_PITCH: float = 3.5
const ENGINE_VOLUME: float = 4.0

@onready var track_path: Path3D = $"../TrackPath"
@onready var track_path_follow: PathFollow3D = $"../TrackPath/TrackPathFollow"
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var track_generator: Node3D = $"../TrackGenerator"

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D

var normal_damping: float
var slow_damping: float

func _ready() -> void:
	super()
	audio_stream_player.volume_db = ENGINE_VOLUME
	normal_damping = damping
	slow_damping = damping / 3.0
	pass

func _physics_process(delta: float) -> void:
	ship_update_engine()
	if not can_move:
		return
	
	if not is_ended:
		if Input.is_action_pressed("Thrust"):
			thrust_mag += THRUST_ACC * delta
		elif thrust_mag > 0.0:
			thrust_mag -= THRUST_DEACC * delta
		if Input.is_action_pressed("TurnLeft"):
			vel_yaw += ROTATION_YAW_SPEED * delta
			vel_roll += ROTATION_ROLL_SPEED * delta
		if Input.is_action_pressed("TurnRight"):
			vel_yaw -= ROTATION_YAW_SPEED * delta
			vel_roll -= ROTATION_ROLL_SPEED * delta
		if Input.is_action_just_pressed("Break"):
			damping = slow_damping
		if Input.is_action_just_released("Break"):
			damping = normal_damping
		if Input.is_action_just_pressed("ui_up"):
			spawn_slow_down_mine()
			EventBuss.on_slow_down_pickup_used()
	else:
		process_auto_pilot(delta, track_path, track_path_follow, track_generator)
		
	mesh_instance_3d.rotation.z = vel_roll
	ship_update(delta, track_path, track_path_follow)	
	pass
	
func ship_update_engine():
	var t = thrust_mag / THRUST_MAX
	audio_stream_player.pitch_scale = lerp(MIN_ENGINE_PITCH, MAX_ENGINE_PITCH, t)	
	cpu_particles_3d.color.a = lerp(0.0, 1.0, t*t)
	pass
	
func start_new_lap():
	super()
	EventBuss.on_player_start_new_lap(max_lap)
	EventBuss.on_player_change_position(current_position)
	pass
	
func set_current_position(pos: int):
	if(pos != current_position && current_lap > 0):
		EventBuss.on_player_change_position(pos)
	super(pos)
	pass
	
func slow_down_mine_grabbed():
	super()
	EventBuss.on_slow_down_pickup_grabbed()
	pass
