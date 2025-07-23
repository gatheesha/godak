extends VBoxContainer

const NOTIFY = preload("res://Notify/notify.tscn")

func _ready() -> void:
	soundboard_manager.print_message.connect(_on_print_message)
	
func _on_print_message(message : String) -> void:
	var noify_instance = NOTIFY.instantiate()
	noify_instance.message = message
	add_child(noify_instance)
	move_child(noify_instance,0)
	
