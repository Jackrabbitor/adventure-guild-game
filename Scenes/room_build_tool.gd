extends Node

@export var camera: Camera3D
@export var grid_manager: GridManager
@export var build_ground: StaticBody3D

var is_dragging: bool = false
var drag_start: Vector2i
var drag_end: Vector2i


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		var grid_position = get_mouse_grid_position()

		if grid_position != null:
			drag_start = grid_position
			is_dragging = true
			print("Started drag at: ", drag_start)

	if Input.is_action_just_released("left_click") and is_dragging:
		var grid_position = get_mouse_grid_position()

		if grid_position != null:
			drag_end = grid_position
			print("Ended drag at: ", drag_end)
			build_room(drag_start, drag_end)

		is_dragging = false


func get_mouse_grid_position():
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

	var grid_position := Vector2i(
		roundi(hit_position.x),
		roundi(hit_position.z)
	)

	return grid_position


func build_room(start: Vector2i, end: Vector2i) -> void:
	var min_x: int = mini(start.x, end.x)
	var max_x: int = maxi(start.x, end.x)
	var min_z: int = mini(start.y, end.y)
	var max_z: int = maxi(start.y, end.y)

	# 1. Place floors inside the room.
	for x in range(min_x, max_x + 1):
		for z in range(min_z, max_z + 1):
			var grid_position := Vector2i(x, z)
			grid_manager.set_floor(grid_position)

	# 2. Place south and north walls.
	for x in range(min_x, max_x + 1):
		var south_cell := Vector2i(x, min_z)
		var north_cell := Vector2i(x, max_z)

		grid_manager.set_wall(
			south_cell,
			grid_manager.WallDirection.SOUTH
		)

		grid_manager.set_wall(
			north_cell,
			grid_manager.WallDirection.NORTH
		)

	# 3. Place west and east walls.
	for z in range(min_z, max_z + 1):
		var west_cell := Vector2i(min_x, z)
		var east_cell := Vector2i(max_x, z)

		grid_manager.set_wall(
			west_cell,
			grid_manager.WallDirection.WEST
		)

		grid_manager.set_wall(
			east_cell,
			grid_manager.WallDirection.EAST
		)

	# 4. Place corner posts.
	var southwest_corner := Vector2i((min_x * 2) - 1, (min_z * 2) - 1)
	var southeast_corner := Vector2i((max_x * 2) + 1, (min_z * 2) - 1)
	var northwest_corner := Vector2i((min_x * 2) - 1, (max_z * 2) + 1)
	var northeast_corner := Vector2i((max_x * 2) + 1, (max_z * 2) + 1)

	grid_manager.set_corner(southwest_corner)
	grid_manager.set_corner(southeast_corner)
	grid_manager.set_corner(northwest_corner)
	grid_manager.set_corner(northeast_corner)
