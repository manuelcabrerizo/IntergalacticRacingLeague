class_name AnimatedButton
extends TextureButton

@export var audio_stream_player: AudioStreamPlayer
@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var pressed_scale: Vector2 = Vector2(0.9, 0.9)

func  _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_entered.connect(_button_enter)
	mouse_exited.connect(_button_exit)
	call_deferred("_init_pivot")
	pass

func _init_pivot() -> void:
	pivot_offset = size/2.0
	pass

func _button_enter() -> void:
	audio_stream_player.play()
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(self, "scale", hover_scale, 0.1).set_trans(Tween.TRANS_SINE)
	pass
	
func _button_exit() -> void:
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(self, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)
	pass
