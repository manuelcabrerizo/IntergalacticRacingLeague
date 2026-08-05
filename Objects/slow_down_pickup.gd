class_name SlowDownPickup
extends Node3D

enum SlowDownPickupType
{
	SLOW_DOWN_MINE = 0,
	SLOW_DOWN_PROJECTILE
}

@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer
@onready var audio_stream_player_split_screen: AudioStreamPlayer = $AudioStreamPlayerSplitScreen

var timer: Timer = null

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 30.0
	timer.timeout.connect(respawn)
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not Ship:
		return
	var ship = body as Ship
	pickup(ship)
	timer.start()
	pass
	
func respawn():
	visible = true
	collision_shape_3d.disabled = false
	pass

func pickup(ship: Ship):
	if GameState.current_gameplay_option == GameState.GameplayOption.SINGLE_PLAYER: 
		audio_stream_player.play()
	elif GameState.current_gameplay_option == GameState.GameplayOption.SPLIT_SCREEN:
		if ship is Player:
			audio_stream_player_split_screen.play()
			
	var slow_down_pick_up_type: SlowDownPickupType = (randi() % 2) as SlowDownPickupType;
	ship.slow_down_pickup_grabbed(slow_down_pick_up_type)
	visible = false
	collision_shape_3d.disabled = true
	pass
	
