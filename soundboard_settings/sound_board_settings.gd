extends VBoxContainer

@export var save_file_dialog : FileDialog
@export var load_file_dialog : FileDialog


func _on_save_button_pressed() -> void:
	save_file_dialog.popup_centered(Vector2(600, 500))


func _on_load_button_pressed() -> void:
	load_file_dialog.popup_centered(Vector2(600, 500))


func _on_new_button_pressed() -> void:
	soundboard_manager.clear_all_audio_clips()


func _on_volume_controller_volume_changed(value: float) -> void:
	pass # Replace with function body.


func _on_save_file_dialog_dir_selected(dir: String) -> void:
	pass # Replace with function body.


func _on_load_file_dialog_file_selected(path: String) -> void:
	soundboard_manager.load_soundboard_from_path(path)


func _on_save_file_dialog_file_selected(path: String) -> void:
	soundboard_manager.save_soundboard_to_path(path)
