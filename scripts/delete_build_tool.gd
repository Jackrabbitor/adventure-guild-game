extends Node

# Handles deleting floor cells while the delete tool is selected.
# GridManager owns the actual data changes and wall rebuilding.

@export var camera: Camera3D
@export var grid_manager: GridManager
@export var build_ground: StaticBody3D
@export var build_mode_manager: BuildModeManager


func _unhandled_input(event: InputEvent) -> void:
	if build_mode_manager == null:
		return

	if not build_mode_manager.is_build_mode_enabled():
		return

	if not build_mode_manager.is_delete_tool_selected():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			delete_clicked_floor()


func delete_clicked_floor() -> void:
	var grid_position = get_mouse_grid_position()

	if grid_position == null:
		return

	if grid_manager == null:
		return

	grid_manager.remove_floor(grid_position)
	print("Deleted floor at: ", grid_position)


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
