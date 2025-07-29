extends Node

const SAVE_FILE_EXTENSION = ".godk"

	
	
func get_audio_stream(path) -> AudioStream:
	var audio_resource : AudioStream
	if FileAccess.file_exists(path):
		if path.ends_with(".mp3"):
			audio_resource = AudioStreamMP3.load_from_file(path)
		elif path.ends_with(".ogg"):
			audio_resource = AudioStreamOggVorbis.load_from_file(path)
		elif path.ends_with(".wav"):
			audio_resource = AudioStreamWAV.load_from_file(path)
	return audio_resource
	
	
func get_file_name(path) -> String:
	var file_name = path.get_file()
	return file_name
#func load_audio_clip_from_data(clip_data: Dictionary) -> void:
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
