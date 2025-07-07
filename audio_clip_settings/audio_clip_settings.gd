extends VBoxContainer

@export var rename_popup : Popup
@export var file_replace_dialog : FileDialog
@export var volume_controller : VolumeController

var audio_clip : AudioClip

func _ready() -> void:
	file_replace_dialog.filters = ["*.wav ; WAV Files", "*.mp3 ; MP3 Files", "*.ogg ; OGG Files"]
	file_replace_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_replace_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_replace_dialog.connect("file_selected", _on_file_selected)
	
	soundboard_manager.audio_clip_settings = self
	visible = false
	
	
func _on_file_selected(path):
	audio_clip.audio_stream = soundboard_manager.get_audio_stream(path)
	
	
func connect_audio_clip(clip : AudioClip) -> void:
	audio_clip = clip
	volume_controller.volume = audio_clip.volume
	visible = true
	
	
func disconnect_audio_clip() -> void:
	audio_clip = null
	visible = false
	
	
func _on_replace_button_pressed() -> void:
	file_replace_dialog.popup_centered(Vector2(600, 500))
	
	
func _on_rename_button_pressed() -> void:
	if audio_clip:
		rename_popup.popup()
	
	
func _on_delete_button_pressed() -> void:
	audio_clip.delete_audio_clip()
	close()
	
	
func _on_cancel_button_pressed() -> void:
	if audio_clip:
		rename_popup.hide()
	%RenameLineEdit.clear()
	
	
func _on_done_button_pressed() -> void:
	if audio_clip:
		if %RenameLineEdit.text:
			audio_clip.display_name = %RenameLineEdit.text
			rename_popup.hide()
	%RenameLineEdit.clear()
	
	
func _on_line_edit_text_submitted(new_text: String) -> void:
	if audio_clip:
		audio_clip.display_name = new_text
	%RenameLineEdit.clear()
	
	
func _on_loop_button_toggled(toggled_on: bool) -> void:
	if audio_clip:
		audio_clip.is_loop_enabled = toggled_on
		
	
func close() -> void:
	visible = false


func _on_volume_controller_volume_changed(value: float) -> void:
	audio_clip.volume = value
