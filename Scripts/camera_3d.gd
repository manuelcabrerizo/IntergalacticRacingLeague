extends Camera3D

@onready var player: Player = $"../Player"

@export var height: float = 7.5
@export var distance: float = 5

var velocity: Vector3 = Vector3.ZERO
var target_position: Vector3

func _physics_process(delta: float) -> void:
	var target = player
	target_position = target.position + target.basis.z * distance + target.basis.y * height
	var movement: Vector3 = target_position - position
	position += movement * (15.0*delta)
	look_at(target.position, target.basis.y)
