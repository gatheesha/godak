class_name DragAndDropMovementComponent
extends TouchScreenButton

@export var actor : Node2D
@export var snap_to_grid_component : SnapToGridComponent

var is_holding : bool = false
var drag_offset : Vector2


func _ready() -> void:
	pressed.connect(_on_pressed)
	released.connect(_on_released)


func _on_pressed() -> void:
	if !actor:
		return

	if !is_holding:
		is_holding = true
		actor.scale *= 1.2
		drag_offset = actor.global_position - get_viewport().get_mouse_position()


func _on_released() -> void:
	if !actor:
		return

	if is_holding:
		is_holding = false
		actor.scale /= 1.2
		if snap_to_grid_component:
			snap_to_grid_component.snap_to_grid()


func _unhandled_input(event: InputEvent) -> void:
	if !is_holding || !actor:
		return
	
	if event is InputEventScreenDrag:
		#get_viewport().set_input_as_handled()
		actor.global_position = event.position + drag_offset
		get_viewport().set_input_as_handled()
	#elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#actor.global_position = event.position + drag_offset
