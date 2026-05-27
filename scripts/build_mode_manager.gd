class_name BuildModeManager
extends Node

# Tracks whether the player is currently in build mode.
# Build mode controls both the visible grid and whether construction tools are allowed.

enum BuildTool {
	ROOM,
	DELETE
}

# The grid visual that appears when build mode is active. Also Build panel
@export var build_grid_visual: Node3D
@export var build_tool_panel: Control
# Starts off so the player begins in normal mode.
var build_mode_enabled: bool = false

# The selected tool inside build mode.
var current_tool: BuildTool = BuildTool.ROOM


func toggle_build_mode() -> void:
	build_mode_enabled = not build_mode_enabled

	# The grid should only be visible while build mode is active.
	if build_grid_visual != null:
		build_grid_visual.visible = build_mode_enabled

	# The build tool menu should appear only while build mode is active.
	if build_tool_panel != null:
		build_tool_panel.visible = build_mode_enabled

	# When opening build mode, default back to the normal room build tool.
	if build_mode_enabled:
		select_room_tool()

	print("Build Mode Is ", build_mode_enabled)


func select_room_tool() -> void:
	current_tool = BuildTool.ROOM
	print("Selected tool: ROOM")


func on_delete_button_pressed() -> void:
	current_tool = BuildTool.DELETE
	print("Selected tool: DELETE")


func is_build_mode_enabled() -> bool:
	return build_mode_enabled


func is_room_tool_selected() -> bool:
	return current_tool == BuildTool.ROOM


func is_delete_tool_selected() -> bool:
	return current_tool == BuildTool.DELETE


# Keyboard shortcut for toggling build mode.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_build_mode"):
		toggle_build_mode()
