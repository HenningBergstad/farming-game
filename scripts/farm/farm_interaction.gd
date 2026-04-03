extends Node

# Drag state
var is_dragging: bool = false
var drag_crop_x: int = -1
var drag_crop_z: int = -1
var drag_preview: PanelContainer = null

# Scene reference #HACK this is temporary
var preview_scene = preload("res://scenes/UI/drag_preview.tscn")

# Node references
@onready var farm = get_parent()
@onready var sell_drawer = farm.get_node("HUD/SellDrawerContainer")
@onready var hud = farm.get_node("HUD")
@onready var camera = get_parent().get_node("CameraOrbit").get_node("Camera3D")
@onready var buy_drawer = farm.get_node("HUD/BuyDrawerContainer")

# Buy drawer interaction
var is_planting: bool = false
var planting_crop_data: CropData = null

func _ready():
	buy_drawer.planting_started.connect(_on_planting_started)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:	
		if event.pressed:
			_start_drag_if_ready()
		else:
			if is_dragging:
				_end_drag()
			elif is_planting:
				_end_planting()
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_handle_right_click()

func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_height = get_viewport().get_visible_rect().size.y
	
	if not is_dragging and not is_planting:
		if mouse_pos.y < screen_height * 0.15:
			buy_drawer.open()
		else:
			buy_drawer.close()
		return
		
	if is_dragging:
		drag_preview.position = mouse_pos - Vector2(20, 20)
		if mouse_pos.y > screen_height * 0.8:
			sell_drawer.open()
		else:
			sell_drawer.peek()
	
	if is_planting:
		drag_preview.position = mouse_pos - Vector2(20, 20)

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

func _start_drag_if_ready() -> void:
	var plot = get_plot_at_mouse()
	if plot.is_empty():
		return
	
	var x = plot[0]
	var z = plot[1]
	
	var current_plot = farm.get_plot(x, z)
	if current_plot.is_ready_to_harvest():
		is_dragging = true
		drag_crop_x = x
		drag_crop_z = z
		
		drag_preview = preview_scene.instantiate()
		hud.add_child(drag_preview)
		drag_preview.setup(current_plot.crop_data.name)
		sell_drawer.peek()

func _end_drag():
	if not is_dragging:
		return
	if sell_drawer.is_mouse_in_sell_zone():
		farm.sell_crop(drag_crop_x, drag_crop_z)
	sell_drawer.close()
	drag_preview.queue_free()
	drag_preview = null
	is_dragging = false

func _handle_right_click() -> void:
	var plot = get_plot_at_mouse()
	if plot.is_empty():
		return
	
	var x = plot[0]
	var z = plot[1]
	
	var current_plot = farm.get_plot(x, z)
	
	var mouse_pos = get_viewport().get_mouse_position()
	farm.get_node("HUD").show_plot_info(current_plot, mouse_pos)

func _on_planting_started(crop_data: CropData) -> void:
	is_planting = true
	planting_crop_data = crop_data
	
	drag_preview = preview_scene.instantiate()
	hud.add_child(drag_preview)
	drag_preview.setup(crop_data.name)
	buy_drawer.close()

func _end_planting() -> void:
	var plot = get_plot_at_mouse()
	if not plot.is_empty():
		var x = plot[0]
		var z = plot[1]
		var current_plot = farm.get_plot(x, z)
		if not current_plot.is_occupied() and PlayerData.spend(planting_crop_data.buy_price):
			farm.plant_crop(x, z, planting_crop_data)
	
	# Always clean up
	buy_drawer.close()
	drag_preview.queue_free()
	drag_preview = null
	is_planting = false
	planting_crop_data = null

		
	
	
