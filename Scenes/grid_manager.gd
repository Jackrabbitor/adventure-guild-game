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

@export var floor_scene: PackedScene
@export var wall_scene: PackedScene
@export var corner_scene: PackedScene

var floor_types: Dictionary = {}
var floor_nodes: Dictionary = {}

var wall_nodes: Dictionary = {}
var corner_nodes: Dictionary = {}


func grid_to_world(grid_position: Vector2i) -> Vector3:
	return Vector3(grid_position.x, 0, grid_position.y)


func set_floor(grid_position: Vector2i) -> void:
	if floor_nodes.has(grid_position):
		floor_nodes[grid_position].queue_free()
		floor_nodes.erase(grid_position)

	floor_types[grid_position] = FloorType.BASIC

	var new_floor: Node3D = floor_scene.instantiate()
	new_floor.position = grid_to_world(grid_position)

	add_child(new_floor)
	floor_nodes[grid_position] = new_floor


func get_wall_key(grid_position: Vector2i, direction: WallDirection) -> String:
	return str(grid_position.x) + "," + str(grid_position.y) + "," + str(direction)


func set_wall(grid_position: Vector2i, direction: WallDirection) -> void:
	var wall_key: String = get_wall_key(grid_position, direction)

	if wall_nodes.has(wall_key):
		wall_nodes[wall_key].queue_free()
		wall_nodes.erase(wall_key)

	var new_wall: Node3D = wall_scene.instantiate()
	new_wall.position = get_wall_world_position(grid_position, direction)
	new_wall.rotation_degrees.y = get_wall_y_rotation(direction)

	add_child(new_wall)
	wall_nodes[wall_key] = new_wall


func get_wall_world_position(grid_position: Vector2i, direction: WallDirection) -> Vector3:
	var x: float = grid_position.x
	var z: float = grid_position.y

	if direction == WallDirection.NORTH:
		return Vector3(x, 0, z + 0.5)
	elif direction == WallDirection.SOUTH:
		return Vector3(x, 0, z - 0.5)
	elif direction == WallDirection.EAST:
		return Vector3(x + 0.5, 0, z)
	elif direction == WallDirection.WEST:
		return Vector3(x - 0.5, 0, z)

	return Vector3(x, 0, z)


func get_wall_y_rotation(direction: WallDirection) -> float:
	if direction == WallDirection.NORTH:
		return 90.0
	elif direction == WallDirection.SOUTH:
		return 90.0
	elif direction == WallDirection.EAST:
		return 0.0
	elif direction == WallDirection.WEST:
		return 0.0

	return 0.0


func get_corner_key(corner_position: Vector2i) -> String:
	return str(corner_position.x) + "," + str(corner_position.y)


func set_corner(corner_position: Vector2i) -> void:
	var corner_key: String = get_corner_key(corner_position)

	if corner_nodes.has(corner_key):
		corner_nodes[corner_key].queue_free()
		corner_nodes.erase(corner_key)

	var new_corner: Node3D = corner_scene.instantiate()
	new_corner.position = get_corner_world_position(corner_position)

	add_child(new_corner)
	corner_nodes[corner_key] = new_corner


func get_corner_world_position(corner_position: Vector2i) -> Vector3:
	return Vector3(corner_position.x * 0.5, 0, corner_position.y * 0.5)
