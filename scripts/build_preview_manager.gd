class_name BuildPreviewManager
extends Node

@export var preview_floor_scene:PackedScene
@export var preview_wall_scene:PackedScene
@export var preview_corner_scene:PackedScene
@export var grid_manager: GridManager

var preview_nodes: Array[Node3D]= []

func clear_preview() -> void:
	for node in preview_nodes:
		node.queue_free()
	preview_nodes.clear()
	
func spawn_preview_floor(grid_position: Vector2i) -> void:
	if preview_floor_scene == null:
		return
	if grid_manager == null:
		return
	
	var preview_floor: Node3D = preview_floor_scene.instantiate()
	preview_floor.position = grid_manager.grid_to_world(grid_position)

	add_child(preview_floor)
	preview_nodes.append(preview_floor)
	
func spawn_preview_wall(grid_position: Vector2i, direction: GridManager.WallDirection) -> void:
	if preview_wall_scene == null:
		return
	if grid_manager == null:
		return
	
	var preview_wall: Node3D = preview_wall_scene.instantiate()
	preview_wall.position = grid_manager.get_wall_world_position(grid_position, direction)
	preview_wall.rotation_degrees.y = grid_manager.get_wall_y_rotation(direction)

	add_child(preview_wall)
	preview_nodes.append(preview_wall)
	

func spawn_preview_corner(corner_position: Vector2i) -> void:
	if preview_corner_scene == null:
		return
	if grid_manager == null:
		return
	var preview_corner: Node3D = preview_corner_scene.instantiate()
	preview_corner.position = grid_manager.get_corner_world_position(corner_position)

	add_child(preview_corner)
	preview_nodes.append(preview_corner)

func show_room_preview(start: Vector2i, end: Vector2i) -> void:
	if grid_manager == null:
		return

	clear_preview()

	var min_x: int = mini(start.x, end.x)
	var max_x: int = maxi(start.x, end.x)
	var min_z: int = mini(start.y, end.y)
	var max_z: int = maxi(start.y, end.y)

	var min_cell := Vector2i(min_x, min_z)
	var max_cell := Vector2i(max_x, max_z)

	for x in range(min_x, max_x + 1):
		for z in range(min_z, max_z + 1):
			spawn_preview_floor(Vector2i(x, z))

	for x in range(min_x, max_x + 1):
		spawn_preview_wall(Vector2i(x, min_z), grid_manager.WallDirection.SOUTH)
		spawn_preview_wall(Vector2i(x, max_z), grid_manager.WallDirection.NORTH)

	for z in range(min_z, max_z + 1):
		spawn_preview_wall(Vector2i(min_x, z), grid_manager.WallDirection.WEST)
		spawn_preview_wall(Vector2i(max_x, z), grid_manager.WallDirection.EAST)

	for corner_position in grid_manager.get_room_corner_lattice_positions(min_cell, max_cell):
		spawn_preview_corner(corner_position)
