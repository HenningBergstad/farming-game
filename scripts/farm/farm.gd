extends Node3D

const GRID_SIZE = 7
const PLOT_SIZE = 1.0

var grid: Array = []
var crop_instances: Array = []
var wind_angle: float = 0.0
var turn_duration: float = GameConfig.TURN_DURATION
var turn_duration_padding: float = GameConfig.TURN_DURATION_PADDING

@onready var next_turn_button = $HUD/Button

func _ready() -> void:
	_init_grid()
	_init_colliders()
	$HUD.next_turn_pressed.connect(_on_next_turn)
	
	# Test: plant corn on plot 0,0
	var test_crop = load("res://resources/crops/corn.tres")
	plant_crop(0, 0, test_crop)

func _init_grid() -> void:
	for x in range(GRID_SIZE):
		var plot_column = []
		var instance_column = []
		for z in range(GRID_SIZE):
			plot_column.append(PlotData.new())
			# null means no crop is planted here yet
			instance_column.append(null)
		grid.append(plot_column)
		crop_instances.append(instance_column)

func get_plot(x: int, z: int) -> PlotData:
	return grid[x][z]

func get_plot_world_position(x: int, z: int) -> Vector3:
	var offset = (GRID_SIZE * PLOT_SIZE) / 2.0
	return Vector3(
		x * PLOT_SIZE - offset + PLOT_SIZE / 2.0,
		0,
		z * PLOT_SIZE - offset + PLOT_SIZE / 2.0
	)

func _on_next_turn() -> void:
	# --- Disable next turn button ---
	next_turn_button.disabled = true
	
	# --- Update the markets ---
	MarketManager.advance_turn()
	
	# --- Shift wind direction ---
	wind_angle += randf_range(0.5, 2.0)
	
	# --- Animate the sun and world environment ---
	animate_sun(turn_duration)
	animate_world_env(turn_duration)
	
	# --- Grow plants and update wind ---
	for x in range(GRID_SIZE):
		for z in range(GRID_SIZE):
			var plot = get_plot(x, z)
			if not plot.is_occupied():
				continue
			
			plot.advance_turn()
			
			var progress = 1.0 - (float(plot.turns_remaining) / float(plot.crop_data.base_growth_time))
			crop_instances[x][z].update_visual(progress, turn_duration)
			crop_instances[x][z].set_wind(wind_angle, turn_duration)
	
	await get_tree().create_timer(turn_duration + turn_duration_padding).timeout
	next_turn_button.disabled = false

func animate_sun(duration: float):
	var sun = $DirectionalLight3D
	
	# --- Rotation ---
	var rotation_tween = create_tween()
	var current_rotation = sun.rotation_degrees
	var target_rotation = current_rotation + Vector3(-360, 0, 0)
	rotation_tween.tween_property(sun, "rotation_degrees", target_rotation, turn_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# --- Color ---
	var color_tween = create_tween()
	var color_midday = Color(1.0, 0.796, 0.453, 1.0)
	var color_sunset = Color(0.781, 0.477, 0.0, 1.0)
	var color_night = Color(0.0, 0.168, 0.323, 1.0)
	var color_sunrise = Color(0.78, 0.478, 0.0, 1.0)
	var color_standard = Color(1.0, 0.741, 0.254, 1.0)
	
	var weights: Array = [
		1.0, 4.0, # midday      tween hold
		2.0, 2.0, # sunset      tween hold
		1.0, 3.0, # night       tween hold
		2.0, 1.0, # sunrise     tween hold
		2.0       # standard    tween
	]
	
	var weight_total = 0.0
	
	for weight in weights:
		weight_total += weight
	
	color_tween.tween_property(sun, "light_color", color_midday, duration * (weights[0] / weight_total))
	color_tween.tween_interval(duration * (weights[1] / weight_total))
	color_tween.tween_property(sun, "light_color", color_sunset, duration * (weights[2] / weight_total))
	color_tween.tween_interval(duration * (weights[3] / weight_total))
	color_tween.tween_property(sun, "light_color", color_night, duration * (weights[4] / weight_total))
	color_tween.tween_interval(duration * (weights[5] / weight_total))
	color_tween.tween_property(sun, "light_color", color_sunrise, duration * (weights[6] / weight_total))
	color_tween.tween_interval(duration * (weights[7] / weight_total))
	color_tween.tween_property(sun, "light_color", color_standard, duration * (weights[8] / weight_total))
	# --- Energy ---
	# var energy_tween = create_tween()

func animate_world_env(duration: float) -> void:
	var world_env = $WorldEnvironment
	var color_tween = create_tween()
	var color_midday = Color(0.966, 0.686, 0.0, 1.0)
	var color_sunset = Color(0.781, 0.477, 0.0, 1.0)
	var color_night = Color(0.0, 0.168, 0.323, 1.0)
	var color_sunrise = Color(0.78, 0.478, 0.0, 1.0)
	var color_standard = Color(1.0, 0.765, 0.35, 1.0)
	
	var weights: Array = [
		1.0, 3.0,# midday      tween hold
		2.0, 2.0, # sunset      tween hold
		1.0, 4.0, # night       tween hold
		2.0, 1.0, # sunrise     tween hold
		1.0       # standard    tween
	]
	
	var weight_total = 0.0
	
	for weight in weights:
		weight_total += weight
	
	color_tween.tween_property(world_env, "environment:ambient_light_color", color_midday, duration * (weights[0] / weight_total))
	color_tween.tween_interval(duration * (weights[1] / weight_total))
	color_tween.tween_property(world_env, "environment:ambient_light_color", color_sunset, duration * (weights[2] / weight_total))
	color_tween.tween_interval(duration * (weights[3] / weight_total))
	color_tween.tween_property(world_env, "environment:ambient_light_color", color_night, duration * (weights[4] / weight_total))
	color_tween.tween_interval(duration * (weights[5] / weight_total))
	color_tween.tween_property(world_env, "environment:ambient_light_color", color_sunrise, duration * (weights[6] / weight_total))
	color_tween.tween_interval(duration * (weights[7] / weight_total))
	color_tween.tween_property(world_env, "environment:ambient_light_color", color_standard, duration * (weights[8] / weight_total))

func plant_crop(x: int, z: int, crop_data: CropData) -> void:
	if get_plot(x, z).is_occupied():
		print("Plot is already occupied!")
		return
	get_plot(x, z).plant(crop_data)
	var instance = Node3D.new()
	instance.set_script(load("res://scripts/crops/crop_instance.gd"))
	add_child(instance)
	instance.setup(get_plot(x, z), get_plot_world_position(x, z))
	crop_instances[x][z] = instance
	# Show initial growth state immediately on planting
	var initial_progress = 1.0 / float(crop_data.base_growth_time)
	crop_instances[x][z].update_visual(initial_progress, 0.5)


func harvest_crop(x: int, z: int) -> void:
	if not get_plot(x, z).is_ready_to_harvest():
		print("Crop is not ready to harvest!")
		return
	var persisted = get_plot(x, z).harvest()
	if persisted:
		# Crop resowed itself, reset to planted stage
		crop_instances[x][z].show_stage("planted")
	else:
		# Remove the crop instance
		crop_instances[x][z].queue_free()
		crop_instances[x][z] = null

func _init_colliders() -> void:
	for x in range(GRID_SIZE):
		for z in range(GRID_SIZE):
			var body = StaticBody3D.new()
			var collision = CollisionShape3D.new()
			var shape = BoxShape3D.new()
			
			# Make the collider flat, mathching the plot size
			shape.size = Vector3(PLOT_SIZE, 0.1, PLOT_SIZE)
			collision.shape = shape
			body.add_child(collision)
			
			# Position it at the plots world position
			body.position = get_plot_world_position(x, z)
			
			# Store the grid coordinates in the bodys metadata
			# so we can identify which plot was clicked later
			body.set_meta("grid_x", x)
			body.set_meta("grid_z", z)
			
			add_child(body)

func sell_crop(x: int, z: int) -> void:
	var plot = get_plot(x, z)
	
	if not plot.is_ready_to_harvest():
		print("Crop is not ready to harvest!")
	
	var sell_price = MarketManager.get_sell_price(plot.crop_data, plot.price_bonus)
	
	var hollow_roll = randf()
	if hollow_roll < plot.hollow_yield:
		# TODO: Hollow yield function for positive soil effects
		MarketManager.record_sale(plot.crop_data)
		harvest_crop(x, z)
	
	PlayerData.earn(sell_price)
	MarketManager.record_sale(plot.crop_data)
	harvest_crop(x, z)
	
	
	
