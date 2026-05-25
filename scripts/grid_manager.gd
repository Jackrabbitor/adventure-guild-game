class_name GridManager
extends Node

enum FloorType {
	NONE,
	BASIC
}

enum WallDirection {
	NORTH,
	EAST,
	SOUTH,
	WEST
}

@export_range(0.01, 64.0, 0.01, "or_greater") var cell_size: float = 2.0
@export var wall_thickness: float = 0.15
@export var wall_inset_padding: float = 0.03
@export var wall_end_overlap: float = 0.08
@export var floor_scene: PackedScene
@export var wall_scene: PackedScene
@export var corner_scene: PackedScene
@export var build_grid_plane: MeshInstance3D

var floor_types: Dictionary = {}
var floor_nodes: Dictionary = {}

var wall_nodes: Dictionary = {}
var corner_nodes: Dictionary = {}


func _ready() -> void:
	sync_build_grid_shader()


func half_cell() -> float:
	return cell_size * 0.5


func cell_center_world(grid_position: Vector2i) -> Vector3:
	return Vector3(
		(grid_position.x + 0.5) * cell_size,
		0.0,
		(grid_position.y + 0.5) * cell_size
	)


func grid_to_world(grid_position: Vector2i) -> Vector3:
	return cell_center_world(grid_position)


func world_to_grid(world_position: Vector3) -> Vector2i:
	return Vector2i(
		roundi(world_position.x / cell_size),
		roundi(world_position.z / cell_size)
	)


func sync_build_grid_shader() -> void:
	if build_grid_plane == null:
		return

	var material := build_grid_plane.get_active_material(0)

	if material is ShaderMaterial:
		material.set_shader_parameter("cell_size", cell_size)


func set_floor(grid_position: Vector2i) -> void:
	if floor_scene == null:
		return

	if floor_nodes.has(grid_position):
		floor_nodes[grid_position].queue_free()
		floor_nodes.erase(grid_position)

	floor_types[grid_position] = FloorType.BASIC

	var new_floor: Node3D = floor_scene.instantiate()
	new_floor.position = cell_center_world(grid_position)

	add_child(new_floor)
	floor_nodes[grid_position] = new_floor


func get_wall_key(grid_position: Vector2i, direction: WallDirection) -> String:
	return str(grid_position.x) + "," + str(grid_position.y) + "," + str(direction)


func set_wall(grid_position: Vector2i, direction: WallDirection) -> void:
	if wall_scene == null:
		return

	var wall_key: String = get_wall_key(grid_position, direction)

	if wall_nodes.has(wall_key):
		wall_nodes[wall_key].queue_free()
		wall_nodes.erase(wall_key)

	var new_wall: Node3D = wall_scene.instantiate()
	new_wall.position = get_wall_world_position(grid_position, direction)
	new_wall.rotation_degrees.y = get_wall_y_rotation(direction)
	new_wall.scale.z = (cell_size + wall_end_overlap) / cell_size

	add_child(new_wall)
	wall_nodes[wall_key] = new_wall


func get_wall_world_position(grid_position: Vector2i, direction: WallDirection) -> Vector3:
	var x_min: float = grid_position.x * cell_size
	var x_max: float = (grid_position.x + 1) * cell_size
	var z_min: float = grid_position.y * cell_size
	var z_max: float = (grid_position.y + 1) * cell_size

	var x_center: float = x_min + half_cell()
	var z_center: float = z_min + half_cell()

	var inset: float = (wall_thickness * 0.5) + wall_inset_padding

	match direction:
		WallDirection.NORTH:
			return Vector3(x_center, 0.0, z_max - inset)
		WallDirection.SOUTH:
			return Vector3(x_center, 0.0, z_min + inset)
		WallDirection.EAST:
			return Vector3(x_max - inset, 0.0, z_center)
		WallDirection.WEST:
			return Vector3(x_min + inset, 0.0, z_center)

	return cell_center_world(grid_position)


func get_wall_y_rotation(direction: WallDirection) -> float:
	match direction:
		WallDirection.NORTH, WallDirection.SOUTH:
			return 90.0
		WallDirection.EAST, WallDirection.WEST:
			return 0.0
		_:
			return 0.0


func get_corner_key(corner_position: Vector2i) -> String:
	return str(corner_position.x) + "," + str(corner_position.y)


func set_corner(corner_position: Vector2i) -> void:
	if corner_scene == null:
		return

	var corner_key: String = get_corner_key(corner_position)

	if corner_nodes.has(corner_key):
		corner_nodes[corner_key].queue_free()
		corner_nodes.erase(corner_key)

	var new_corner: Node3D = corner_scene.instantiate()
	new_corner.position = get_corner_world_position(corner_position)

	add_child(new_corner)
	corner_nodes[corner_key] = new_corner


func get_corner_world_position(corner_position: Vector2i) -> Vector3:
	return Vector3(
		corner_position.x * cell_size,
		0.0,
		corner_position.y * cell_size
	)


func get_room_corner_lattice_positions(min_cell: Vector2i, max_cell: Vector2i) -> Array[Vector2i]:
	var corners: Array[Vector2i] = []

	corners.append(Vector2i(min_cell.x, min_cell.y))
	corners.append(Vector2i(max_cell.x + 1, min_cell.y))
	corners.append(Vector2i(min_cell.x, max_cell.y + 1))
	corners.append(Vector2i(max_cell.x + 1, max_cell.y + 1))

	return corners
func get_room_layout(start: Vector2i, end: Vector2i) -> Dictionary:
	var min_x: int = mini(start.x, end.x)
	var max_x: int = maxi(start.x, end.x)
	var min_z: int = mini(start.y, end.y)
	var max_z: int = maxi(start.y, end.y)

	var floors: Array[Vector2i] = []
	var walls: Array[Dictionary] = []
	var corners: Array[Vector2i] = []

	for x in range(min_x, max_x + 1):
		for z in range(min_z, max_z + 1):
			floors.append(Vector2i(x, z))

	for x in range(min_x, max_x + 1):
		walls.append({
			"cell": Vector2i(x, min_z),
			"direction": WallDirection.SOUTH
		})

		walls.append({
			"cell": Vector2i(x, max_z),
			"direction": WallDirection.NORTH
		})

	for z in range(min_z, max_z + 1):
		walls.append({
			"cell": Vector2i(min_x, z),
			"direction": WallDirection.WEST
		})

		walls.append({
			"cell": Vector2i(max_x, z),
			"direction": WallDirection.EAST
		})

	var min_cell := Vector2i(min_x, min_z)
	var max_cell := Vector2i(max_x, max_z)
	
	corners = get_room_corner_lattice_positions(min_cell, max_cell)

	return {
		"floors": floors,
		"walls": walls,
		"corners": corners
	}
