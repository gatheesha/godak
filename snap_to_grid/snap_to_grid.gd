class_name SnapToGridComponent
extends Node

@export var actor : Node2D
@export var snap_to_grid_stats : SnapToGridStats


func snap_to_grid():
	var pos: Vector2

	pos = actor.transform.origin
	actor.transform.origin = Vector2(
		pos.x + snap_to_grid_stats.position_offset.x,
		pos.y + snap_to_grid_stats.position_offset.y,
	)

	pos = actor.transform.origin

	if snap_to_grid_stats.x_axis:
		actor.transform.origin.x = round(
			(pos.x - snap_to_grid_stats.positioning_offset.x) / snap_to_grid_stats.positioning_step.x
		) * snap_to_grid_stats.positioning_step.x + snap_to_grid_stats.positioning_offset.x

	if snap_to_grid_stats.y_axis:
		actor.transform.origin.y = round(
			(pos.y - snap_to_grid_stats.positioning_offset.y) / snap_to_grid_stats.positioning_step.y
		) * snap_to_grid_stats.positioning_step.y + snap_to_grid_stats.positioning_offset.y

	snap_to_grid_stats.scaling_step.x = min(1, snap_to_grid_stats.scaling_step.x)
	snap_to_grid_stats.scaling_step.y = min(1, snap_to_grid_stats.scaling_step.y)

	var local_scale: Vector2 = actor.scale
	actor.scale = Vector2(
		round(local_scale.x / snap_to_grid_stats.scaling_step.x) * snap_to_grid_stats.scaling_step.x,
		round(local_scale.y / snap_to_grid_stats.scaling_step.y) * snap_to_grid_stats.scaling_step.y
	)
