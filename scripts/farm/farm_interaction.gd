extends Node

@onready var farm = get_parent()
@onready var camera = get_parent().get_node("CameraOrbit").get_node("Camera3D")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var plot = get_plot_at_mouse()
	
		if plot.is_empty():
			return
		
		var x = plot[0]
		var z = plot[1]
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(x, z)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_right_click(x, z)

func get_plot_at_mouse() -> Array:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 100.0
	
	var space_state = get_parent().get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		return []
	
	var body = result.collider
	if not body.has_meta("grid_x"):
		return[]
	
	return [body.get_meta("grid_x"), body.get_meta("grid_z")]
	
func _handle_left_click(x: int, z: int) -> void:
	farm.get_node("HUD").close_plot_info()
	var plot = farm.get_plot(x, z)
	if plot.is_ready_to_harvest():
		farm.sell_crop(x, z)
	elif not plot.is_occupied():
		var test_crop = load("res://resources/crops/corn.tres")
		farm.plant_crop(x, z, test_crop)

func _handle_right_click(x: int, z: int) -> void:
	var plot = farm.get_plot(x, z)
	var mouse_pos = get_viewport().get_mouse_position()
	farm.get_node("HUD").show_plot_info(plot, mouse_pos)
