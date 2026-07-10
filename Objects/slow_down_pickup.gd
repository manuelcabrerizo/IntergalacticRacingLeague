class_name SlowDownPickup
extends Node3D

@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D

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
	ship.slow_down_mine_grabbed()
	pickup()
	timer.start()
	pass
	
func respawn():
	visible = true
	collision_shape_3d.disabled = false
	pass

func pickup():
	visible = false
	collision_shape_3d.disabled = true
	pass
	
