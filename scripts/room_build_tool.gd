extends Node

# Handles player input for room building.
# This script does not place objects directly except by asking GridManager and BuildPreviewManager.
# RoomBuildTool handles the drag interaction; GridManager handles the actual construction data.


# -------------------------------------------------------------------
# Inspector references
# -------------------------------------------------------------------

@export var camera: Camera3D
@export var grid_manager: GridManager
@export var build_ground: StaticBody3D
@export var build_preview_manager: BuildPreviewManager
@export var build_mode_manager: BuildModeManager


# -------------------------------------------------------------------
# Drag state
# -------------------------------------------------------------------

var is_dragging: bool = false
var drag_start: Vector2i
var drag_end: Vector2i


# -------------------------------------------------------------------
# Per-frame preview update
# -------------------------------------------------------------------

func _process(_delta: float) -> void:
	if build_mode_manager == null:
		return

	if not build_mode_manager.is_build_mode_enabled():
		return

	if not build_mode_manager.is_room_tool_selected():
		return

	update_room_preview()


func update_room_preview() -> void:
	if not is_dragging:
		return

	var grid_position = get_mouse_grid_position()

	if grid_position == null:
		return

	if build_preview_manager == null:
		return

	if grid_manager == null:
		return

	var is_valid: bool = grid_manager.can_build_room(drag_start, grid_position)
	build_preview_manager.show_room_preview(drag_start, grid_position, is_valid)


# -------------------------------------------------------------------
# Input handling
# -------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if build_mode_manager == null:
		return

	if not build_mode_manager.is_build_mode_enabled():
		return

	if not build_mode_manager.is_room_tool_selected():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			start_room_drag()

		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			finish_room_drag()


func start_room_drag() -> void:
	var grid_position = get_mouse_grid_position()

	if grid_position == null:
		return

	drag_start = grid_position
	is_dragging = true

	print("Started drag at: ", drag_start)


func finish_room_drag() -> void:
	if not is_dragging:
		return

	var grid_position = get_mouse_grid_position()

	clear_current_preview()

	if grid_position == null:
		is_dragging = false
		return

	drag_end = grid_position

	print("Ended drag at: ", drag_end)

	if grid_manager == null:
		is_dragging = false
		return

	if not grid_manager.can_build_room(drag_start, drag_end):
		print("Invalid room placement")
		is_dragging = false
		return

	build_room(drag_start, drag_end)

	is_dragging = false


func clear_current_preview() -> void:
	if build_preview_manager != null:
		build_preview_manager.clear_preview()


# -------------------------------------------------------------------
# Mouse/grid helpers
# -------------------------------------------------------------------

# Shoots a ray from the camera through the mouse position.
# If it hits the build ground, we convert that world hit position into a grid cell.
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
		print("Mouse did not hit anything.")
		return null

	if result["collider"] != build_ground:
		print("Mouse hit something else: ", result["collider"].name)
		return null

	var hit_position: Vector3 = result["position"]

	return grid_manager.world_to_grid(hit_position)


# -------------------------------------------------------------------
# Room construction
# -------------------------------------------------------------------

# Builds the final room.
# Floors are placed first, then GridManager rebuilds walls from all existing floors.
func build_room(start: Vector2i, end: Vector2i) -> void:
	if grid_manager == null:
		return

	var layout: Dictionary = grid_manager.get_room_layout(start, end)

	for floor_position in layout["floors"]:
		grid_manager.set_floor(floor_position)

	grid_manager.rebuild_all_walls()
