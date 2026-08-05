class_name SlowDownMine
extends Node3D

var instigator: Ship = null
var target_scale: Vector3
var start_scale: Vector3
var is_dropped: bool = false
var ships: Array[Ship]

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var audio_stream_player_split_screen: AudioStreamPlayer = $AudioStreamPlayerSplitScreen
@onready var visual: MeshInstance3D = $Visual

func _ready() -> void:
	is_dropped = false
	start_scale = Vector3(0.1, 0.1, 0.1)
	target_scale = visual.scale
	visual.scale = start_scale
	var tween = create_tween()
	tween.tween_property(visual, "scale", target_scale, 0.25).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(on_drop)
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 15.0
	timer.one_shot = true
	timer.timeout.connect(shrink_and_destroy)
	timer.start()
	pass
	
func _process(_delta: float) -> void:
	if not is_dropped:
		position = instigator.position;
	pass

func set_instigator(new_instigator: Ship):
	instigator = new_instigator
	play_spawn_sound()
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	var ship = body as Ship
	if(instigator == ship):
		return
	ship.damping = 0.01
	ships.push_back(ship)
	pass

func _on_area_3d_body_exited(body: Node3D) -> void:
	var ship = body as Ship
	if(instigator == ship):
		return
	ship.damping = 0.8
	pass
	
func shrink_and_destroy() -> void:
	var tween = create_tween()
	tween.tween_property(visual, "scale", start_scale, 0.25).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(on_destroy)
	
func on_drop():
	is_dropped = true;
	pass
	
func on_destroy():
	for ship in ships:
		if is_instance_valid(ship):
			ship.damping = 0.8
	queue_free()
	pass
	
func play_spawn_sound():
	if GameState.current_gameplay_option == GameState.GameplayOption.SINGLE_PLAYER: 
		audio_stream_player_3d.play()
	elif GameState.current_gameplay_option == GameState.GameplayOption.SPLIT_SCREEN:
		if instigator is Player:
			audio_stream_player_split_screen.play()
	pass
