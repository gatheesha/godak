extends GridContainer

const NEW_CLIP = preload("res://audio_clip/new_clip.tscn")

var last_clip_node
var last_new_node

func _ready() -> void:
	soundboard_manager.audio_grid = self
	soundboard_manager.window_resized.connect(on_window_resized)
	soundboard_manager.window_resized.emit()
	create_new_clip_node()


func on_window_resized()-> void:
	var v : float = get_viewport_rect().size.x / (192 + 32)
	columns = int(v)


func _on_child_entered_tree(node: Node) -> void:
	if is_instance_valid(last_new_node):
		last_new_node.queue_free()
	if node is AudioClip:
		create_new_clip_node()
		last_clip_node = node
	
	
func create_new_clip_node()-> void:
	var new_clip_instance = NEW_CLIP.instantiate()
	add_child(new_clip_instance)
	last_new_node = new_clip_instance
