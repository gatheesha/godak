extends Node

const AUDIO_CLIP = preload("res://audio_clip/audio_clip.tscn")
const SAVE_FILE_EXTENSION = ".godk"

var audio_grid
var audio_clip_settings

var current_base_color : Color
var base_color : Color = Color.BLACK

var soundboard: Array[AudioClip] = []

signal stop_all_sounds
signal window_resized

signal clip_settings_closed
signal print_message(message : String)

func _ready():
	OS.request_permissions()
	print(OS.get_granted_permissions())
	#pass
	# Create default save directory if it doesn't exist
	#if not DirAccess.dir_exists_absolute(DEFAULT_SAVE_DIRECTORY):
		#DirAccess.open("user://").make_dir_recursive_absolute(DEFAULT_SAVE_DIRECTORY)
	#
	
	
func save_soundboard_to_path(full_path: String) -> bool:
	var save_data = {
		"version": "1.0",
		"created_at": Time.get_datetime_string_from_system(),
		"audio_clips": []
	}
	
	# Collect all audio clip data
	for clip in soundboard:
		var clip_data = {
			"display_name": clip.display_name,
			"original_name": clip.original_name,
			"volume": clip.volume,
			"is_loop_enabled": clip.is_loop_enabled,
			"audio_path": clip.audio_file_path
		}
		save_data.audio_clips.append(clip_data)
	
	# Ensure file has correct extension
	if not full_path.ends_with(SAVE_FILE_EXTENSION):
		full_path += SAVE_FILE_EXTENSION
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	
	if file == null:
		soundboard_manager.push_notification("Failed to create save file: " + full_path)
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	soundboard_manager.push_notification("Soundboard saved successfully: " + full_path)
	return true
	
	
func load_soundboard_from_path(full_path: String) -> bool:
	if not FileAccess.file_exists(full_path):
		soundboard_manager.push_notification("Save file not found: " + full_path)
		return false
	
	var file = FileAccess.open(full_path, FileAccess.READ)
	if file == null:
		soundboard_manager.push_notification("Failed to open save file: " + full_path)
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		soundboard_manager.push_notification("Failed to parse save file JSON: " + full_path)
		return false
	
	var save_data = json.data
	
	# Validate save data structure
	if not save_data.has("audio_clips"):
		soundboard_manager.push_notification("Invalid save file format: missing audio_clips")
		return false
	
	clear_soundboard()
	
	# Load audio clips
	for clip_data in save_data.audio_clips:
		var audio_clip_instance : AudioClip = AUDIO_CLIP.instantiate()
		
		# Set basic properties
		audio_clip_instance.original_name = clip_data.get("original_name", "Unknown")
		audio_clip_instance.display_name = clip_data.get("display_name", audio_clip_instance.original_name)
		audio_clip_instance.volume = clip_data.get("volume", 100.0)
		audio_clip_instance.is_loop_enabled = clip_data.get("is_loop_enabled", false)
		audio_grid.add_child(audio_clip_instance)
		soundboard.append(audio_clip_instance)
	
	soundboard_manager.push_notification("Soundboard loaded successfully: " + full_path)
	return true
	
	
func clear_soundboard() -> void:
	for audio_clip in soundboard:
		if is_instance_valid(audio_clip):
			audio_clip.queue_free()
	soundboard.clear()
	
	
func create_audio_clip_from_path(path : String) -> void:
	var audio_stream = file_manager.get_audio_stream(path)
	if audio_stream:
		var audio_clip_instance : AudioClip = AUDIO_CLIP.instantiate()
		audio_clip_instance.audio_stream = audio_stream
		audio_clip_instance.original_name = file_manager.get_file_name(path)
		audio_clip_instance.audio_file_path = path
		audio_grid.add_child(audio_clip_instance)
		soundboard.append(audio_clip_instance)
		
		
func cleanup_soundboard() -> void:
	for clip in soundboard:
		if !is_instance_valid(clip):
			soundboard.erase(clip)
#func create_audio_clip_from_soundboard(soundboard: Array[AudioClip]) -> void:
	#var audio_clip_instance : AudioClip = AUDIO_CLIP.instantiate()
	#
	## Set basic properties
	#audio_clip_instance.original_name = clip_data.get("original_name", "Unknown")
	#audio_clip_instance.display_name = clip_data.get("display_name", audio_clip_instance.original_name)
	#audio_clip_instance.volume = clip_data.get("volume", 100.0)
	#audio_clip_instance.is_loop_enabled = clip_data.get("is_loop_enabled", false)
	#
	## Try to load audio stream if path exists
	#var audio_path = clip_data.get("audio_path", "")
	#if audio_path != "":
		#audio_clip_instance.audio_file_path = audio_path
		#if FileAccess.file_exists(audio_path):
			#var audio_stream = get_audio_stream(audio_path)
			#if audio_stream:
				#audio_clip_instance.audio_stream = audio_stream
		#else:
			#push_message("Warning: Audio file not found: " + audio_path)
	#
	#audio_grid.add_child(audio_clip_instance)
	#sounds.append(audio_clip_instance)
	
	
func toggle_audio_settings_on(clip : AudioClip) -> void:
	clip_settings_closed.emit()
	audio_clip_settings.connect_audio_clip(clip)
	
	
func toggle_audio_settings_off()-> void:
	audio_clip_settings.disconnect_audio_clip()
	clip_settings_closed.emit()
	
	
func set_master_volume(volume_percent: float) -> void:
	volume_percent = clamp(volume_percent, 0.0, 100.0)
	var volume_db = remap(volume_percent, 0.0, 100.0, -80.0, 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)


func get_master_volume() -> float:
	var volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	return remap(volume_db, -80.0, 0.0, 0.0, 100.0)
	
	
func push_notification(message : String):
	print_message.emit(message)
	
	
