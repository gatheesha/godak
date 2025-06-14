extends Control

@export var audio_grid : GridContainer 
@export var file_dialog : FileDialog

var audio_resources = {}


func _ready():
	file_dialog.filters = ["*.wav ; WAV Files", "*.mp3 ; MP3 Files", "*.ogg ; OGG Files"]
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.connect("files_selected", _on_files_selected)
	
	get_viewport().files_dropped.connect(_on_files_dropped)


func load_project():
	pass


func save_project():
	pass


func _on_import_button_pressed():
	file_dialog.popup_centered(Vector2(800, 600))


func _on_files_selected(paths):
	for path in paths:
		load_audio_file(path)


func _on_files_dropped(files):
	for file_path in files:
		if file_path.ends_with(".mp3") or file_path.ends_with(".wav") or file_path.ends_with(".ogg"):
			load_audio_file(file_path)


func load_audio_file(path):
	print(path)
	#var player = AudioStreamPlayer.new()
	
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
	
	
	if audio_resource:
		var file_name = path.get_file()
		var new_audio_clip = AudioClip.new(file_name, audio_resource)
		audio_grid.add_child(new_audio_clip)
		#player.stream = audio_resource
		#new_audio_clip.audio_stream_player.stream = audio_resource
		
		#var audio_button = Button.new()
		
		#audio_button.text = file_name
		#new_audio_clip.display_name = file_name
		
		#audio_button.pressed.connect(_on_audio_button_pressed.bind(file_name))
		
		#audio_grid.add_child(audio_button)
		#add_child(player)
		
		#audio_resources[file_name] = player
	else:
		print("Failed to load audio file: ", path)


func _on_audio_button_pressed(file_name):
	if audio_resources.has(file_name):
		for resource in audio_resources.values():
			if resource.playing:
				resource.stop()
		
		audio_resources[file_name].play()


func _on_import_pressed() -> void:
	file_dialog.popup_centered(Vector2(600, 500))
