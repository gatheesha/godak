extends ColorRect


func _process(delta: float) -> void:
	color = soundboard_manager.current_base_color
