class_name BuildModeManager
extends Node

@export var build_grid_visual: Node3D

var build_mode_enabled: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_build_mode"):
		build_mode_enabled = not build_mode_enabled
		if build_grid_visual != null:
			build_grid_visual.visible = build_mode_enabled
		print("Build Mode Is ", build_mode_enabled)

func is_build_mode_enabled() -> bool:
	return build_mode_enabled
	
