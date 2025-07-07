extends HBoxContainer
class_name VolumeController

var volume : float = 100.0:
	set(value):
		volume = value
		update_slider(value)

@onready var volume_slider: HSlider = %VolumeSlider

signal volume_changed(value : float)


func update_slider(value : float) -> void:
	volume_slider.value = value


func _on_increase_button_pressed() -> void:
	volume_slider.value += volume_slider.step


func _on_decrease_button_pressed() -> void:
	volume_slider.value -= volume_slider.step


func _on_volume_slider_value_changed(value: float) -> void:
	volume = value
	volume_changed.emit(volume)


func _on_save_button_pressed() -> void:
	pass # Replace with function body.


func _on_load_button_pressed() -> void:
	pass # Replace with function body.


func _on_new_button_pressed() -> void:
	pass # Replace with function body.
