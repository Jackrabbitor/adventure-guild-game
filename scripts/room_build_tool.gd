extends Node

@export var camera: Camera3D
@export var grid_manager: GridManager
@export var build_ground: StaticBody3D
@export var build_preview_manager: BuildPreviewManager
@export var build_mode_manager: BuildModeManager

var is_dragging: bool = false
var drag_start: Vector2i
var drag_end: Vector2i


func _process(_delta: float) -> void:
	if build_mode_manager == null:
		return
	if not build_mode_manager.is_build_mode_enabled():
		return
		
	if Input.is_action_just_pressed("left_click"):
		var grid_position = get_mouse_grid_position()

		if grid_position != null:
			drag_start = grid_position
			is_dragging = true
			print("Started drag at: ", drag_start)

	if is_dragging:
		var grid_position = get_mouse_grid_position()

		if grid_position != null and build_preview_manager != null:
			build_preview_manager.show_room_preview(drag_start, grid_position)

	if Input.is_action_just_released("left_click") and is_dragging:
		var grid_position = get_mouse_grid_position()

		if grid_position != null:
			drag_end = grid_position
			print("Ended drag at: ", drag_end)

			if build_preview_manager != null:
				build_preview_manager.clear_preview()

			build_room(drag_start, drag_end)

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
		print("Mouse did not hit anything.")
		return null

	if result["collider"] != build_ground:
		print("Mouse hit something else: ", result["collider"].name)
		return null

	var hit_position: Vector3 = result["position"]

	return grid_manager.world_to_grid(hit_position)


func build_room(start: Vector2i, end: Vector2i) -> void:
	if grid_manager == null:
		return

	var layout: Dictionary = grid_manager.get_room_layout(start, end)

	for floor_position in layout["floors"]:
		grid_manager.set_floor(floor_position)

	for wall_data in layout["walls"]:
		grid_manager.set_wall(wall_data["cell"], wall_data["direction"])

# Indoor rooms do not currently use visible corner posts.
# Corner layout logic stays in GridManager for future outdoor/structure tools.
	# for corner_position in layout["corners"]:
	# 	grid_manager.set_corner(corner_position)
