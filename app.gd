extends Control

func _ready() -> void:
	get_viewport().files_dropped.connect(_on_files_dropped)
	

func _on_files_dropped(files):
	for file_path in files:
		if file_path.ends_with(".mp3") or file_path.ends_with(".wav") or file_path.ends_with(".ogg"):
			soundboard_manager.create_new_audio_clip(file_path)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			soundboard_manager.toggle_audio_settings_off()
