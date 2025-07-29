extends VBoxContainer

const NOTIFICATION = preload("res://notifcations/notifications.tscn")


func _ready() -> void:
	soundboard_manager.print_message.connect(_on_print_message)
	
	
func _on_print_message(message : String) -> void:
	var notification_instance = NOTIFICATION.instantiate()
	notification_instance.message = message
	add_child(notification_instance)
	move_child(notification_instance,0)
	
