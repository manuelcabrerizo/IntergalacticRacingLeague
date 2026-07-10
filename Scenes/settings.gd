class_name Settings
extends Control

@onready var music_slider: HSlider = $ColorRect/MusicSlider/MusicSlider
@onready var sfx_slider: HSlider = $ColorRect/SfxSlider/SfxSlider
@onready var ui_slider: HSlider = $ColorRect/UISlider/UISlider

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sfx")))
	ui_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("UI")))
	pass

func _on_back_button_button_down() -> void:
	EventBuss.on_setting_back_button_clicked()
	pass

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	pass

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(value))
	pass
	
func _on_ui_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear_to_db(value))
	pass
