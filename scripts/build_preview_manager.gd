class_name BuildPreviewManager
extends Node

# Handles the temporary hologram preview while the player is dragging out a room.

# Preview scenes assigned in the Inspector.
@export var preview_floor_scene: PackedScene
@export var preview_wall_scene: PackedScene
@export var preview_corner_scene: PackedScene

# GridManager used for all placement math
@export var grid_manager: GridManager

# Stores every preview piece spawned
var preview_nodes: Array[Node3D] = []


# Clears all current hologram preview pieces.
func clear_preview() -> void:
	for node in preview_nodes:
		node.queue_free()

	preview_nodes.clear()


# Spawns temporary preview floor at a grid cell.
func spawn_preview_floor(grid_position: Vector2i) -> void:
	if preview_floor_scene == null:
		return

	if grid_manager == null:
		return

	var preview_floor: Node3D = preview_floor_scene.instantiate()
	preview_floor.position = grid_manager.grid_to_world(grid_position)

	add_child(preview_floor)
	preview_nodes.append(preview_floor)


# Spawns temporary preview wall at a grud cell
func spawn_preview_wall(grid_position: Vector2i, direction: GridManager.WallDirection) -> void:
	if preview_wall_scene == null:
		return

	if grid_manager == null:
		return

	var preview_wall: Node3D = preview_wall_scene.instantiate()
	preview_wall.position = grid_manager.get_wall_world_position(grid_position, direction)
	preview_wall.rotation_degrees.y = grid_manager.get_wall_y_rotation(direction)

	# Match the real wall overlap so the preview corners line up with the final build.
	preview_wall.scale.z = (grid_manager.cell_size + grid_manager.wall_end_overlap) / grid_manager.cell_size

	add_child(preview_wall)
	preview_nodes.append(preview_wall)


# Kept for future corner/post previews.
func spawn_preview_corner(corner_position: Vector2i) -> void:
	if preview_corner_scene == null:
		return

	if grid_manager == null:
		return

	var preview_corner: Node3D = preview_corner_scene.instantiate()
	preview_corner.position = grid_manager.get_corner_world_position(corner_position)

	add_child(preview_corner)
	preview_nodes.append(preview_corner)


# Redraws the full room preview from drag start to the current mouse cell.
# It uses GridManager's room layout.
func show_room_preview(start: Vector2i, end: Vector2i) -> void:
	if grid_manager == null:
		return

	clear_preview()

	var layout: Dictionary = grid_manager.get_room_layout(start, end)

	for floor_position in layout["floors"]:
		spawn_preview_floor(floor_position)

	for wall_data in layout["walls"]:
		spawn_preview_wall(wall_data["cell"], wall_data["direction"])

	# Indoor room preview does not currently show visible corner posts.
	# Corner layout logic stays in GridManager for future outdoor/structure tools.
	# for corner_position in layout["corners"]:
	# 	spawn_preview_corner(corner_position)
