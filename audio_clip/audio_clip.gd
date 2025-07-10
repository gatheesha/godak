class_name AudioClip
extends PanelContainer

var display_name : String = "":
	set(value):
		display_name = value
		update_display_name(display_name)
		
var audio_stream : AudioStream = null:
	set(value):
		audio_stream = value
		update_audio_stream(audio_stream)
		
var is_loop_enabled : bool
var original_name : String
var audio_file_path : String = ""
var is_playing : bool
var color : Color
var duration : float
var volume : float = 100.0:
	set (value):
		volume = value
		update_volume(volume)

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var display_name_label: Label = %DisplayName
@onready var button: Button = %Button
@onready var button_hold_timer: Timer = %ButtonHoldTimer
@onready var panel_container: PanelContainer = self


func _ready() -> void:
	display_name = original_name
	update_display_name(display_name)
	update_audio_stream(audio_stream)
	update_volume(100.0)
	soundboard_manager.stop_all_sounds.connect(_on_stop_all_sounds)
	update_panel_random_hue()
	
	

func update_panel_random_hue():
	var style_box: StyleBoxFlat = panel_container.get_theme_stylebox("panel")
	var current_color = style_box.bg_color
	var random_hue = randf_range(0.0,1.0)
	var new_color = Color.from_hsv(random_hue, 0.7, 1.0, current_color.a)
	style_box.bg_color = new_color
	#panel_container.add_theme_stylebox_override("panel", style_box)
	
	color = new_color
	
	
func update_display_name(new_name : String) -> void:
	if display_name_label:
		display_name_label.text = new_name
	if is_instance_valid(button):
		button.text = new_name
	
	
func update_audio_stream(new_stream : AudioStream) -> void:
	if audio_stream_player and new_stream:
		audio_stream_player.stream = new_stream
		duration = new_stream.get_length()
	
	
func update_volume(new_volume : float) -> void:
	if is_instance_valid(audio_stream_player):
		audio_stream_player.volume_db = remap(new_volume, 0, 100, -80, 0)
	
	
func _on_button_pressed() -> void:
	audio_stream_player.play()
	soundboard_manager.update_base_color(color, duration)
	
	
func _on_stop_all_sounds() -> void:
	if audio_stream_player.playing:
		audio_stream_player.stop()
	
	
func _on_button_button_down() -> void:
	button_hold_timer.start()
	
	
func _on_button_button_up() -> void:
	button_hold_timer.stop()
	
	
func _on_button_hold_timer_timeout() -> void:
	soundboard_manager.toggle_audio_settings_on(self)
	
	
func delete_audio_clip() -> void:
	queue_free()
	
	
func _on_audio_stream_player_finished() -> void:
	if is_loop_enabled:
		audio_stream_player.play()
	soundboard_manager.update_base_color(Color.BLACK, duration/4)
