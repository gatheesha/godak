extends PanelContainer

const ANIMATE_DURATION : float = 0.2

@export var file_dialog : FileDialog
var tween

func _ready():
	$FileDialog.root_subfolder = "/storage/emulated/0"
	scale = Vector2(0,0)
	pivot_offset = size/2
	spawn_animation()
	file_dialog.filters = ["*.wav ; WAV Files", "*.mp3 ; MP3 Files", "*.ogg ; OGG Files"]
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.connect("files_selected", _on_files_selected)
	
	
func _on_files_selected(paths):
	for path in paths:
		soundboard_manager.create_new_audio_clip(path)
	

func _on_button_pressed() -> void:
	if !file_dialog.visible:
		file_dialog.popup_centered(Vector2(600, 500))
	press_animation()
	
	
func press_animation() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self,"scale",Vector2(0.9, 0.9), ANIMATE_DURATION)
	tween.tween_property(self,"scale",Vector2(1, 1), ANIMATE_DURATION)
	
	
func spawn_animation() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"scale",Vector2(1.0, 1.0), ANIMATE_DURATION)
