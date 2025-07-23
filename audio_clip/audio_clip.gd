class_name AudioClip
extends PanelContainer

const ANIMATE_OFFSET_X : float = 8
const ANIMATE_OFFSET_Y : float = 16
const ANIMATE_DURATION : float = 0.2

enum BUTTON_STATUS {
	PRESSED,
	NORMAL
}
var button_status : BUTTON_STATUS = BUTTON_STATUS.NORMAL
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
var duration : float
var volume : float = 100.0:
	set (value):
		volume = value
		update_volume(volume)
		
var shake_strengh : float = 0
var shake_strengh_smooth : float = 0

var color : Color = Color.WHITE
var color_smooth : Color = Color.WHITE

var tween : Tween
var stop_overlay_visible : bool = false

var is_settings_enabled : bool = false

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var display_name_label: Label = %DisplayName
@onready var button: Button = %Button
@onready var button_hold_timer: Timer = %ButtonHoldTimer
@onready var panel_container: PanelContainer = self
@onready var shadow : MarginContainer = %Shadow
@onready var init_position : Vector2 = self.get_position()
@onready var stop_overlay: MarginContainer = %StopOverlay
@onready var stop_timer: Timer = %StopTimer


func _ready() -> void:
	display_name = original_name
	update_display_name(display_name)
	update_audio_stream(audio_stream)
	update_volume(100.0)
	soundboard_manager.window_resized.emit()
	soundboard_manager.stop_all_sounds.connect(_on_stop_all_sounds)
	soundboard_manager.window_resized.connect(_on_window_resized)
	soundboard_manager.clip_settings_closed.connect(_on_clip_settings_closed)
	stop_overlay.modulate.a = 0
	stop_overlay.visible = false
	await get_tree().process_frame
	animate_clip_show()
	
	
func _process(delta: float) -> void:
	shake_strengh_smooth = lerp(shake_strengh_smooth, shake_strengh,delta * 5)
	self.get_material().set_shader_parameter("strength", shake_strengh_smooth)
	
	color_smooth = lerp(color_smooth, color, delta * 2)
	self.modulate = color_smooth
	
	#print(self.get_material().get_shader_parameter("strength"))
	if audio_stream_player.playing and !is_playing:
		is_playing = true
		shake_strengh += 10.0
		animate_button_press()
		stop_timer.start()
	if !audio_stream_player.playing and is_playing:
		is_playing = false
		shake_strengh -= 10.0
		animate_button_release()
		animate_stop_overlay_hide()
		stop_timer.stop()
	
	
func update_display_name(new_name : String) -> void:
	if is_instance_valid(display_name_label):
		display_name_label.text = new_name
	#if is_instance_valid(button):
		#button.text = new_name
	
	
func update_audio_stream(new_stream : AudioStream) -> void:
	if audio_stream_player and new_stream:
		audio_stream_player.stream = new_stream
		duration = new_stream.get_length()
	
	
func update_volume(new_volume : float) -> void:
	if is_instance_valid(audio_stream_player):
		audio_stream_player.volume_db = remap(new_volume, 0, 100, -80, 0)
	
	
func _on_button_pressed() -> void:
	if !is_settings_enabled:
		audio_stream_player.play()
	#soundboard_manager.update_base_color(color, duration)
	
	
func _on_stop_all_sounds() -> void:
	if audio_stream_player.playing:
		audio_stream_player.stop()
	
	
func _on_button_button_down() -> void:
	button_hold_timer.start()
	color = Color("dff262")
	shake_strengh += 4.0
	#button_status = BUTTON_STATUS.HOLD
	
func _on_button_button_up() -> void:
	button_hold_timer.stop()
	if !is_settings_enabled:
		color = Color.WHITE
		shake_strengh -= 4.0
	#shake_strengh = 0.0
	#if button_status == BUTTON_STATUS.HOLD:
		#shake_strengh = 0
func _on_clip_settings_closed() -> void:
	if is_settings_enabled:
		color = Color.WHITE
		shake_strengh -= 4.0
	is_settings_enabled = false
	
	
func _on_button_hold_timer_timeout() -> void:
	soundboard_manager.toggle_audio_settings_on(self)
	is_settings_enabled = true
	
	
func delete_audio_clip() -> void:
	queue_free()
	
	
func _on_audio_stream_player_finished() -> void:
	if is_loop_enabled:
		audio_stream_player.play()
	#soundboard_manager.update_base_color(Color.BLACK, duration/4)
	
	
func _on_window_resized() -> void:
	return
	var v : float = get_viewport_rect().size.x / 8
	print(v)
	custom_minimum_size.x = v
	
	
func animate_button_press() -> void:
	if button_status != BUTTON_STATUS.NORMAL:
		return
	if tween:
		if tween.is_running():
			await tween.finished
		tween.kill()
	button_status = BUTTON_STATUS.PRESSED
	tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_method(tween_shadow, Vector2(shadow.get("theme_override_constants/margin_right"), shadow.get("theme_override_constants/margin_bottom")), Vector2(0,0), ANIMATE_DURATION)
	tween.tween_property(self,"position",Vector2(self.position.x + ANIMATE_OFFSET_X, self.position.y + ANIMATE_OFFSET_Y), ANIMATE_DURATION)
	
	
func animate_button_release() -> void:
	if button_status != BUTTON_STATUS.PRESSED:
		return
	if tween:
		if tween.is_running():
			await tween.finished
		tween.kill()
	button_status = BUTTON_STATUS.NORMAL
	tween = create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_method(tween_shadow, Vector2(shadow.get("theme_override_constants/margin_right"), shadow.get("theme_override_constants/margin_bottom")), Vector2(- ANIMATE_OFFSET_X, - ANIMATE_OFFSET_Y), ANIMATE_DURATION)
	tween.tween_property(self,"position",Vector2(self.position.x - ANIMATE_OFFSET_X, self.position.y - ANIMATE_OFFSET_Y), ANIMATE_DURATION)
	
	
func animate_stop_overlay_show() -> void:
	stop_overlay.visible = true
	var stop_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	stop_overlay.modulate.a = 0
	stop_overlay.scale = Vector2(0.8, 0.8)
	stop_tween.parallel().tween_property(stop_overlay, "modulate:a", 1.0, ANIMATE_DURATION)
	stop_tween.parallel().tween_property(stop_overlay, "scale", Vector2(1.0, 1.0), ANIMATE_DURATION)
	
	
func animate_stop_overlay_hide() -> void:
	var stop_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	stop_tween.parallel().tween_property(stop_overlay, "modulate:a", 0.0, ANIMATE_DURATION)
	stop_tween.parallel().tween_property(stop_overlay, "scale", Vector2(0.8, 0.8), ANIMATE_DURATION)
	await stop_tween.finished
	stop_overlay.visible = false
	
	
func tween_shadow(value : Vector2):
	shadow.add_theme_constant_override("margin_bottom",value.y)
	shadow.add_theme_constant_override("margin_right", value.x)
	
	
func _on_stop_timer_timeout() -> void:
	animate_stop_overlay_show()
	
	
func animate_clip_show() -> void:
	$SpawnSound.play()
	var clip_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	self.modulate.a = 0
	self.scale = Vector2(0.0, 0.0)
	self.pivot_offset = size/2
	clip_tween.parallel().tween_property(self, "modulate:a", 1.0, ANIMATE_DURATION)
	clip_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), ANIMATE_DURATION)
	
	
func _on_stop_button_pressed() -> void:
	audio_stream_player.stop()
