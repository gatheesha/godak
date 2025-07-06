class_name AudioClip
extends PanelContainer

#@export var sound_effect
var original_name : String
var display_name : String

var is_playing : bool
var is_loop_enabled : bool
var is_fading_enabled : bool

var audio_stream : AudioStream

#func _init(current_name : String, stream : AudioStream) -> void:
	#pass
	#display_name = current_name
	#audio_stream = stream



func _ready() -> void:
	display_name = original_name
	%DisplayName.text = display_name
	%Button.text = display_name
	%AudioStreamPlayer.stream = audio_stream


func _on_button_pressed() -> void:
	%AudioStreamPlayer.play()
