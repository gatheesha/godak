extends MarginContainer

@export var file_dialog : FileDialog


func _ready():
	file_dialog.filters = ["*.wav ; WAV Files", "*.mp3 ; MP3 Files", "*.ogg ; OGG Files"]
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.connect("files_selected", _on_files_selected)
	
	
func _on_files_selected(paths):
	for path in paths:
		soundboard_manager.create_new_audio_clip(path)
	
	
func _on_import_pressed() -> void:
	file_dialog.popup_centered(Vector2(600, 500))
	
	
func _on_stop_pressed() -> void:
	soundboard_manager.stop_all_sounds.emit()
	
	
func _on_settings_toggled(toggled_on: bool) -> void:
	%SoundboardSettings.visible = toggled_on
