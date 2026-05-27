extends Node

# Handles deleting floor cells while the delete tool is selected.
# The player can drag out a rectangle and delete all floors inside it.

@export var camera: Camera3D
@export var grid_manager: GridManager
@export var build_ground: StaticBody3D
@export var build_mode_manager: BuildModeManager
@export var build_preview_manager: BuildPreviewManager

var is_dragging: bool = false
var drag_start: Vector2i
var drag_end: Vector2i

func _process(_delta: float) -> void:
	if build_mode_manager == null:
		return

	if not build_mode_manager.is_build_mode_enabled():
		return

	if not build_mode_manager.is_delete_tool_selected():
		return

	if not is_dragging:
		return

	if build_preview_manager == null:
		return

	var grid_position = get_mouse_grid_position()

	if grid_position == null:
		return

	# Delete preview should always be red, so we pass false.
	build_preview_manager.show_room_preview(drag_start, grid_position, false)

func _unhandled_input(event: InputEvent) -> void:
	if build_mode_manager == null:
		return

	if not build_mode_manager.is_build_mode_enabled():
		return

	if not build_mode_manager.is_delete_tool_selected():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_delete_drag()

		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			finish_delete_drag()


func start_delete_drag() -> void:
	var grid_position = get_mouse_grid_position()

	if grid_position == null:
		return

	drag_start = grid_position
	is_dragging = true

	print("Started delete drag at: ", drag_start)


func finish_delete_drag() -> void:
	if not is_dragging:
		return

	var grid_position = get_mouse_grid_position()

	if build_preview_manager != null:
		build_preview_manager.clear_preview()

	if grid_position == null:
		is_dragging = false
		return

	drag_end = grid_position

	if grid_manager == null:
		is_dragging = false
		return

	grid_manager.remove_floor_area(drag_start, drag_end)

	print("Deleted floor area from ", drag_start, " to ", drag_end)

	is_dragging = false


func get_mouse_grid_position():
	if camera == null:
		return null

	if grid_manager == null:
		return null

	if build_ground == null:
		return null

	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)

	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_direction * 1000.0
	)

	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result: Dictionary = space_state.intersect_ray(query)

	if result.is_empty():
		return null

	if result["collider"] != build_ground:
		return null

	var hit_position: Vector3 = result["position"]

	return grid_manager.world_to_grid(hit_position)
