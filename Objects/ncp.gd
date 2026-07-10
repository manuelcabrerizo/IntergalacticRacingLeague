class_name Npc
extends Ship

@onready var track_path: Path3D = $"../../TrackPath"
@onready var track_path_follow: PathFollow3D = $"../../TrackPath/TrackPathFollow"
@onready var track_generator: Node3D = $"../../TrackGenerator"
@onready var shape_cast_3d: ShapeCast3D = $ShapeCast3D

@onready var visual: Node3D = $Visual
@onready var racing_bolid: Node3D = $Visual/RacingBolid
@onready var racing_ship: Node3D = $Visual/RacingShip
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var label: Label = $Sprite3D/SubViewport/Label
@onready var cpu_particles_3d: CPUParticles3D = $Visual/CPUParticles3D

const SHIP_REPULSION_FORCE = 75.0
const NPC_MAX_VELOCITY = 300.0
const NPC_MIN_VELOCITY = 100.0

var slow_down_mine_timer: Timer = null

func _ready() -> void:
	super()
	if randi() % 2:
		racing_bolid.visible = false
		racing_ship.visible = true
	else:
		racing_bolid.visible = true
		racing_ship.visible = false
	
	max_velocity = randf_range(NPC_MIN_VELOCITY, NPC_MAX_VELOCITY);
	var random_color = Color(randf(), randf(), randf())
	sprite_3d.modulate = random_color
	sprite_3d.visible = false
	
	slow_down_mine_timer = Timer.new()
	add_child(slow_down_mine_timer)
	slow_down_mine_timer.one_shot = true
	slow_down_mine_timer.timeout.connect(fire_slow_down_mine)
	pass

func _physics_process(delta: float) -> void:
	ship_update_enigne()
	if not can_move:
		return
	process_auto_pilot(delta, track_path, track_path_follow, track_generator)
	add_repulsion_force_from_other_ships()
	visual.rotation.z = vel_roll
	ship_update(delta, track_path, track_path_follow)
	pass

func add_repulsion_force_from_other_ships():
	var ships: Array[Ship] = get_nearby_ships()
	for ship in ships:
		var from_ship: Vector3 = position - ship.position
		var resulsion_direction: Vector3 = basis.x * basis.x.dot(from_ship) 
		var repulsion_t = clamp((1.0 - (resulsion_direction.length() / 10.0)), 0.0, 1.0)
		var repulsion_magnitude: float = repulsion_t * SHIP_REPULSION_FORCE
		force += resulsion_direction.normalized() * repulsion_magnitude
	pass
	
func get_nearby_ships() -> Array[Ship]:
	var ships: Array[Ship] = []
	shape_cast_3d.add_exception(self)
	shape_cast_3d.force_shapecast_update()
	for i in shape_cast_3d.get_collision_count():
		var collision_object = shape_cast_3d.get_collider(i)
		if collision_object is Ship:
			ships.append(collision_object)
	return ships
	
func set_current_position(pos: int):
	if(current_lap > 0):
		label.text = "P" + str(pos)
	super(pos)
	pass
	
func start_new_lap():
	super()
	sprite_3d.visible = true
	pass

func ship_update_enigne():
	var t = thrust_mag / THRUST_MAX
	cpu_particles_3d.color.a = lerp(0.0, 1.0, t*t)
	pass
	
func slow_down_mine_grabbed():
	super()
	slow_down_mine_timer.wait_time = randf_range(4.0, 20.0)
	slow_down_mine_timer.start()
	pass
	
func fire_slow_down_mine():
	spawn_slow_down_mine()
	pass
