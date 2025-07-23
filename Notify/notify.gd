extends MarginContainer

@export var message : String = ""

func _ready() -> void:
	$Label.text = message

func _on_timer_timeout() -> void:
	queue_free()
