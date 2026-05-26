class_name BuildModeManager
extends Node

# Tracks whether the player is currently in build mode.

# The grid that appears when build mode is active.
@export var build_grid_visual: Node3D

# Starts off
var build_mode_enabled: bool = false

func toggle_build_mode() -> void: 
	build_mode_enabled = not build_mode_enabled
		# The grid should only be visible while build mode is active.
	if build_grid_visual != null:
		build_grid_visual.visible = build_mode_enabled

		print("Build Mode Is ", build_mode_enabled)


# Toggles
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_build_mode"):
		toggle_build_mode()
	

# Other scripts use this instead of directly checking the variable.
func is_build_mode_enabled() -> bool:
	return build_mode_enabled


func _on_build_button_pressed() -> void:
	toggle_build_mode()
