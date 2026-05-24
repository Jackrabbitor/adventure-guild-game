extends Node3D

@export var camera: Camera3D

@export var move_speed: float = 12.0
@export var rotation_speed: float = 90.0
@export var zoom_levels: Array[float] = [7.0, 14.0, 22.0]
@export var zoom_smooth_speed: float = 10.0
@export var pitch_speed: float = 45.0

@export var mouse_rotation_sensitivity: float = 0.25
@export var mouse_pitch_sensitivity: float = 0.25

@export var min_zoom: float = 6.0
@export var max_zoom: float = 24.0

@export var min_pitch: float = -75.0
@export var max_pitch: float = -25.0

var is_middle_mouse_rotating: bool = false
var zoom_index: int= 1
var target_zoom: float = 0.0

func _ready() -> void:
	if camera == null:
		return
	zoom_index = 1
	target_zoom = zoom_levels[zoom_index]
	camera.size = target_zoom
	

func _process(delta: float) -> void:
	handle_movement(delta)
	handle_keyboard_rotation(delta)
	handle_zoom()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		handle_mouse_button_event(event)

	if event is InputEventMouseMotion:
		handle_mouse_motion_event(event)


func handle_movement(delta: float) -> void:
	var input_direction := Vector3.ZERO

	if Input.is_action_pressed("camera_forward"):
		input_direction.z -= 1

	if Input.is_action_pressed("camera_backward"):
		input_direction.z += 1

	if Input.is_action_pressed("camera_left"):
		input_direction.x -= 1

	if Input.is_action_pressed("camera_right"):
		input_direction.x += 1

	if input_direction == Vector3.ZERO:
		return

	input_direction = input_direction.normalized()

	var movement: Vector3 = global_transform.basis * input_direction
	movement.y = 0
	movement = movement.normalized()

	global_position += movement * move_speed * delta


func handle_keyboard_rotation(delta: float) -> void:
	var rotation_input: float = 0.0

	if Input.is_action_pressed("camera_rotate_left"):
		rotation_input += 1.0

	if Input.is_action_pressed("camera_rotate_right"):
		rotation_input -= 1.0

	if rotation_input == 0.0:
		return

	rotation_degrees.y += rotation_input * rotation_speed * delta


func handle_zoom() -> void:
	if camera == null:
		return

	if Input.is_action_just_pressed("camera_zoom_in"):
		zoom_index -= 1

	if Input.is_action_just_pressed("camera_zoom_out"):
		zoom_index += 1

	zoom_index = clamp(zoom_index, 0, zoom_levels.size()-1)
	target_zoom = zoom_levels[zoom_index]

	camera.size = lerp(camera.size, target_zoom, zoom_smooth_speed * get_process_delta_time())


func handle_mouse_button_event(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_MIDDLE:
		is_middle_mouse_rotating = event.pressed


func handle_mouse_motion_event(event: InputEventMouseMotion) -> void:
	if not is_middle_mouse_rotating:
		return

	# Move mouse left/right to rotate around the map.
	rotation_degrees.y -= event.relative.x * mouse_rotation_sensitivity

	# Move mouse up/down to change camera pitch.
	if camera != null:
		camera.rotation_degrees.x -= event.relative.y * mouse_pitch_sensitivity
		camera.rotation_degrees.x = clamp(
			camera.rotation_degrees.x,
			min_pitch,
			max_pitch
		)
