extends Node3D

const MAX_TILT = 5.0

const LERP_WEIGHT = 0.04

var target_rotation: Vector3 = Vector3.ZERO

func _process(_delta: float) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	
	var normalised_x = (mouse_pos.x / viewport_size.x) * 2.0 - 1.0
	var normalised_y = (mouse_pos.y / viewport_size.y) * 2.0 - 1.0
	
	target_rotation.x = -normalised_y * MAX_TILT
	target_rotation.y = -normalised_x * MAX_TILT
	
	rotation_degrees.x = lerp(rotation_degrees.x, target_rotation.x, LERP_WEIGHT)
	rotation_degrees.y = lerp(rotation_degrees.y, target_rotation.y, LERP_WEIGHT)
	
