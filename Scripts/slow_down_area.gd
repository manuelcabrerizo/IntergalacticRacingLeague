extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is not Npc:
		return
	body.damping = 0.3
	pass

func _on_body_exited(body: Node3D) -> void:
	if body is not Npc:
		return
	body.damping = 0.8
	pass
