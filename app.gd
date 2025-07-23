extends Control

func _ready() -> void:
	get_viewport().files_dropped.connect(_on_files_dropped)
	request_storage_permissions()
	
	
func request_storage_permissions():
	print("Requesting storage permissions...")
	
	if OS.get_name() != "Android":
		print("Not on Android, permissions not needed")
		return true
	
	# Check current permissions
	var current_permissions = OS.get_granted_permissions()
	print("Current permissions: ", current_permissions)
	
	# Request permissions
	var permission_requested = OS.request_permissions()
	print("Permission request result: ", permission_requested)
	
	# Wait a moment for user to respond, then check again
	await get_tree().create_timer(1.0).timeout
	
	var new_permissions = OS.get_granted_permissions()
	print("Permissions after request: ", new_permissions)
	
	# Check if we have storage permission
	var has_storage = false
	for permission in new_permissions:
		if "STORAGE" in permission or "READ_EXTERNAL_STORAGE" in permission:
			has_storage = true
			break
	
	if has_storage:
		print("✓ Storage permissions granted!")
		return true
	else:
		print("✗ Storage permissions denied")
		return false


func _on_files_dropped(files):
	for file_path in files:
		if file_path.ends_with(".mp3") or file_path.ends_with(".wav") or file_path.ends_with(".ogg"):
			soundboard_manager.create_new_audio_clip(file_path)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			soundboard_manager.toggle_audio_settings_off()


func _on_resized() -> void:
	soundboard_manager.window_resized.emit()
