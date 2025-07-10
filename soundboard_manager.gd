extends Node

const AUDIO_CLIP = preload("res://audio_clip/audio_clip.tscn")
const SAVE_FILE_EXTENSION = ".godk"
const DEFAULT_SAVE_DIRECTORY = "user://sound_file_godawal/"

var audio_grid
var audio_clip_settings

var current_base_color : Color
var base_color : Color = Color.BLACK

var sounds: Array[AudioClip] = []

signal stop_all_sounds

func _ready():
	# Create default save directory if it doesn't exist
	if not DirAccess.dir_exists_absolute(DEFAULT_SAVE_DIRECTORY):
		DirAccess.open("user://").make_dir_recursive_absolute(DEFAULT_SAVE_DIRECTORY)
		
		
func update_base_color(new_color : Color, duration : float = 1.0):
	var tween : Tween = create_tween()
	tween.tween_method(set_current_base_color, current_base_color, new_color, duration)

func set_current_base_color(new_color : Color):
	current_base_color = new_color


#func _process(delta: float) -> void:
	#current_base_color = lerp(current_base_color, base_color, delta)
#

func get_audio_stream(path) -> AudioStream:
	var audio_resource : AudioStream
	if path.ends_with(".mp3"):
		if FileAccess.file_exists(path):
			audio_resource = AudioStreamMP3.load_from_file(path)
	elif path.ends_with(".ogg"):
		if FileAccess.file_exists(path):
			audio_resource = AudioStreamOggVorbis.load_from_file(path)
	elif path.ends_with(".wav"):
		if FileAccess.file_exists(path):
			audio_resource = AudioStreamWAV.load_from_file(path)
	return audio_resource
	
	
func get_file_name(path) -> String:
	var file_name = path.get_file()
	return file_name
	
	
func create_new_audio_clip(path : String) -> void:
	var audio_stream = get_audio_stream(path)
	if audio_stream:
		var audio_clip_instance : AudioClip = AUDIO_CLIP.instantiate()
		audio_clip_instance.audio_stream = audio_stream
		audio_clip_instance.original_name = get_file_name(path)
		audio_clip_instance.audio_file_path = path
		audio_grid.add_child(audio_clip_instance)
		sounds.append(audio_clip_instance)
	
	
func toggle_audio_settings_on(clip : AudioClip) -> void:
	audio_clip_settings.connect_audio_clip(clip)
	
	
func toggle_audio_settings_off()-> void:
	audio_clip_settings.disconnect_audio_clip()
	
	
# ========== SAVE/LOAD FUNCTIONS ==========

func save_soundboard_to_path(full_path: String) -> bool:
	var save_data = {
		"version": "1.0",
		"created_at": Time.get_datetime_string_from_system(),
		"audio_clips": []
	}
	
	# Collect all audio clip data
	for clip in sounds:
		if is_instance_valid(clip):
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
	print(full_path)
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	
	if file == null:
		push_error("Failed to create save file: " + full_path)
		return false
	
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Soundboard saved successfully: " + full_path)
	return true


func save_soundboard(file_name: String) -> bool:
	# Legacy function for backwards compatibility - saves to default directory
	var full_path = DEFAULT_SAVE_DIRECTORY + file_name
	return save_soundboard_to_path(full_path)


func load_soundboard_from_path(full_path: String) -> bool:
	if not FileAccess.file_exists(full_path):
		push_error("Save file not found: " + full_path)
		return false
	
	var file = FileAccess.open(full_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: " + full_path)
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save file JSON: " + full_path)
		return false
	
	var save_data = json.data
	
	# Validate save data structure
	if not save_data.has("audio_clips"):
		push_error("Invalid save file format: missing audio_clips")
		return false
	
	# Clear existing audio clips
	clear_all_audio_clips()
	
	# Load audio clips
	for clip_data in save_data.audio_clips:
		load_audio_clip_from_data(clip_data)
	
	print("Soundboard loaded successfully: " + full_path)
	return true


func load_soundboard(file_name: String) -> bool:
	# Legacy function for backwards compatibility - loads from default directory
	if not file_name.ends_with(SAVE_FILE_EXTENSION):
		file_name += SAVE_FILE_EXTENSION
	
	var full_path = DEFAULT_SAVE_DIRECTORY + file_name
	return load_soundboard_from_path(full_path)


func load_audio_clip_from_data(clip_data: Dictionary) -> void:
	var audio_clip_instance : AudioClip = AUDIO_CLIP.instantiate()
	
	# Set basic properties
	audio_clip_instance.original_name = clip_data.get("original_name", "Unknown")
	audio_clip_instance.display_name = clip_data.get("display_name", audio_clip_instance.original_name)
	audio_clip_instance.volume = clip_data.get("volume", 100.0)
	audio_clip_instance.is_loop_enabled = clip_data.get("is_loop_enabled", false)
	
	# Try to load audio stream if path exists
	var audio_path = clip_data.get("audio_path", "")
	if audio_path != "":
		audio_clip_instance.audio_file_path = audio_path
		if FileAccess.file_exists(audio_path):
			var audio_stream = get_audio_stream(audio_path)
			if audio_stream:
				audio_clip_instance.audio_stream = audio_stream
		else:
			print("Warning: Audio file not found: " + audio_path)
	
	audio_grid.add_child(audio_clip_instance)
	sounds.append(audio_clip_instance)


func clear_all_audio_clips() -> void:
	for clip in sounds:
		if is_instance_valid(clip):
			clip.queue_free()
	sounds.clear()


func get_available_save_files_in_directory(directory_path: String) -> Array[String]:
	var save_files: Array[String] = []
	var dir = DirAccess.open(directory_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(SAVE_FILE_EXTENSION):
				save_files.append(file_name)
			file_name = dir.get_next()
	
	return save_files


func get_available_save_files() -> Array[String]:
	# Legacy function - returns files from default directory
	return get_available_save_files_in_directory(DEFAULT_SAVE_DIRECTORY)


func delete_save_file_at_path(full_path: String) -> bool:
	if FileAccess.file_exists(full_path):
		var dir = DirAccess.open(full_path.get_base_dir())
		if dir:
			dir.remove(full_path.get_file())
			print("Save file deleted: " + full_path)
			return true
	return false


func delete_save_file(file_name: String) -> bool:
	# Legacy function - deletes from default directory
	if not file_name.ends_with(SAVE_FILE_EXTENSION):
		file_name += SAVE_FILE_EXTENSION
	
	var full_path = DEFAULT_SAVE_DIRECTORY + file_name
	return delete_save_file_at_path(full_path)


func get_save_file_info_from_path(full_path: String) -> Dictionary:
	var info = {}
	
	if FileAccess.file_exists(full_path):
		var file = FileAccess.open(full_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var save_data = json.data
				info = {
					"version": save_data.get("version", "Unknown"),
					"created_at": save_data.get("created_at", "Unknown"),
					"audio_clip_count": save_data.get("audio_clips", []).size(),
					"file_size": FileAccess.get_file_as_bytes(full_path).size(),
					"file_path": full_path
				}
	
	return info


func get_save_file_info(file_name: String) -> Dictionary:
	# Legacy function - gets info from default directory
	if not file_name.ends_with(SAVE_FILE_EXTENSION):
		file_name += SAVE_FILE_EXTENSION
	
	var full_path = DEFAULT_SAVE_DIRECTORY + file_name
	return get_save_file_info_from_path(full_path)


# ========== FILE DIALOG HELPER FUNCTIONS ==========

func show_save_dialog(parent_node: Node, callback: Callable) -> void:
	var file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.add_filter("*" + SAVE_FILE_EXTENSION, "Soundboard Files")
	file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	
	parent_node.add_child(file_dialog)
	file_dialog.popup_centered_ratio(0.8)
	
	file_dialog.file_selected.connect(func(path: String):
		var success = save_soundboard_to_path(path)
		callback.call(success, path)
		file_dialog.queue_free()
	)
	
	file_dialog.canceled.connect(func():
		callback.call(false, "")
		file_dialog.queue_free()
	)


func show_load_dialog(parent_node: Node, callback: Callable) -> void:
	var file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*" + SAVE_FILE_EXTENSION, "Soundboard Files")
	file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	
	parent_node.add_child(file_dialog)
	file_dialog.popup_centered_ratio(0.8)
	
	file_dialog.file_selected.connect(func(path: String):
		var success = load_soundboard_from_path(path)
		callback.call(success, path)
		file_dialog.queue_free()
	)
	
	file_dialog.canceled.connect(func():
		callback.call(false, "")
		file_dialog.queue_free()
	)


# ========== ENHANCED AUDIO CLIP MANAGEMENT ==========

func remove_audio_clip(clip: AudioClip) -> void:
	if clip in sounds:
		sounds.erase(clip)
	clip.queue_free()


func get_audio_clip_count() -> int:
	return sounds.size()


func get_audio_clip_by_name(clip_name: String) -> AudioClip:
	for clip in sounds:
		if is_instance_valid(clip) and clip.display_name == clip_name:
			return clip
	return null


# ========== UTILITY FUNCTIONS ==========

func export_soundboard_list(export_path: String) -> bool:
	# Export a list of all soundboards with their info
	var export_data = {
		"export_date": Time.get_datetime_string_from_system(),
		"soundboards": []
	}
	
	# This would need to be implemented based on your specific needs
	# For now, it's a placeholder for future functionality
	
	var file = FileAccess.open(export_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(export_data, "\t"))
		file.close()
		return true
	return false



func set_master_volume(volume_percent: float) -> void:
	volume_percent = clamp(volume_percent, 0.0, 100.0)
	var volume_db = remap(volume_percent, 0.0, 100.0, -80.0, 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)


func get_master_volume() -> float:
	var volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	return remap(volume_db, -80.0, 0.0, 0.0, 100.0)
