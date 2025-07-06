extends Node

const AUDIO_CLIP = preload("res://audio_clip/audio_clip.tscn")

var audio_grid
var audio_clip_settings

var sounds: Array[AudioClip] = []

signal stop_all_sounds


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
		audio_grid.add_child(audio_clip_instance)
	
	
func toggle_audio_settings_on(clip : AudioClip) -> void:
	audio_clip_settings.connect_audio_clip(clip)
	
	
func toggle_audio_settings_off()-> void:
	audio_clip_settings.disconnect_audio_clip()
	
	
