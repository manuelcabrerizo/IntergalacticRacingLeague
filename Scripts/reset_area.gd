extends Area3D
@onready var track_path: Path3D = $"../TrackPath"

func _on_body_entered(body: Node3D) -> void:
	if body is not Ship:
		return
	var ship := body as Ship
	ship.ship_reset(track_path)
	pass
