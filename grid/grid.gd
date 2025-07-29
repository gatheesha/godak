extends TextureRect


func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _process(delta: float) -> void:
	var cam_zoom = get_viewport().get_camera_2d().zoom
	print(cam_zoom)
	#size *= cam_zoom

func _on_camera_2d_zoom_changed(zoom_value: Vector2) -> void:
	#scale = zoom_value
	pass


func _on_viewport_size_changed() -> void:
	size = get_viewport_rect().size
	print(size)
