class_name PlantInstance
extends Node3D

# This script is the "builder" that reads a PlantDefinition and creates
## the actual 3D meshes (stems, leaves, fruit) in the scene.
## It also handles updating the visuals as the plant grows each turn.

# --- References to the data ---
var plot_data: PlotData = null
var plant_def: PlantDefinition = null

# --- Track the current growth so we know when fruit should appear ---
var growth_progress: float = 0.0

# --- Arrays to keep track of everything we've built ---
# Each entry is a Dictionary with keys: "mesh" (MeshInstance3D), "target_height" (float)
var stem_data: Array = []

# Each entry is a Dictionary with keys: "mesh" (MeshInstance3D), "stem_index" (int)
var leaf_data: Array = []

# Each entry is a MeshInstance3D (the fruit sphere)
var fruit_data: Array = []

# --- Wind sway ---
# The current wind direction in radians (set by the farm each turn)
var wind_angle: float = 0.0
# How strongly the wind affects this plant (randomized per-plant for variety)
var wind_sensitivity: float = 1.0
# Time accumulator for the sine wave animation
var _sway_time: float = 0.0
# Whether sway is active (disabled during growth tweens to avoid fighting)
var _sway_enabled: bool = false

# How long the current turn's animation lasts (set each turn)
var _current_turn_duration: float = 0.5


func setup(plot: PlotData) -> void:
	plot_data = plot
	plant_def = plot.crop_data.plant_definition
	
	if plant_def == null:
		push_warning("No PlantDefinition foun for crop: " + plot.crop_data.name)
		return
	_build_plant()
	
	# Each plant sways slightly differently so they don't all move in sync
	wind_sensitivity = randf_range(0.7, 1.3)
	# Start the sway time at a random offset so plants aren't synchronized
	_sway_time = randf() * TAU
	_sway_enabled = true

func _process(delta: float) -> void:
	## Runs every frame. Applies a gentle wind sway to all stems.
	if not _sway_enabled or stem_data.is_empty():
		return
	
	_sway_time += delta
	
	# Base sway amount — scales with how grown the plant is
	# (tiny seedlings shouldn't sway much, tall plants sway more)
	var sway_strength = 2.5 * growth_progress * wind_sensitivity
	
	# Use sine waves at slightly different speeds for organic movement
	# The wind_angle controls WHICH DIRECTION the stems lean
	var sway_x = sin(_sway_time * 1.8) * sway_strength * cos(wind_angle)
	var sway_z = sin(_sway_time * 2.1 + 0.7) * sway_strength * sin(wind_angle)
	
	for stem in stem_data:
		var mesh: MeshInstance3D = stem["mesh"]
		# Only apply sway if the stem isn't being shaken by fruit pop
		# We check if rotation is being tweened by seeing if it's close to target
		var pivot: Node3D = stem["pivot"]
		pivot.rotation_degrees.x = sway_x
		pivot.rotation_degrees.z = sway_z

func set_wind(angle: float, duration: float = 0.5) -> void:
	## Smoothly transitions to a new wind direction over the turn duration.
	var tween = create_tween()
	tween.tween_property(self, "wind_angle", angle, duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)

func _build_plant() -> void:
	_clear_plant()
	_build_stems()
	_build_leaves()
	_build_fruit()
	
func _clear_plant() -> void:
	for child in get_children():
		child.queue_free()
	stem_data.clear()
	leaf_data.clear()
	fruit_data.clear()

func _build_stems() -> void:
	var stem_def = plant_def.stem_definition
	if stem_def == null:
		push_warning("No StemDefinition on PlantDefinition for: " + plot_data.crop_data.name)
		return
	
	for i in range(plant_def.stem_count):
		var stem = _create_single_stem(stem_def, i)
		stem_data.append(stem)

func _create_single_stem(stem_def: StemDefinition, _index: int) -> Dictionary:
	var height_variation = randf_range(-1.0, 1.0) * plant_def.height_randomness
	var target_height = plant_def.max_height * (1.0 + height_variation)
	
	# --- Create a pivot node at ground level ---
	# This is the "base" of the stem. When we rotate the pivot,
	# the stem swings from the bottom like a real plant.
	var pivot = Node3D.new()
	
	var mesh_instance = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	
	cylinder.top_radius = stem_def.thickness * 0.5
	cylinder.bottom_radius = stem_def.thickness
	cylinder.height = 1.0
	
	mesh_instance.mesh = cylinder
	
	var material = StandardMaterial3D.new()
	material.albedo_color = stem_def.color
	mesh_instance.material_override = material
	
	# --- Position the stem ABOVE the pivot ---
	# The pivot sits at ground level. The mesh hangs above it.
	# Since the cylinder is centered on its origin, we push it up
	# by half its height so the bottom touches the pivot point.
	# At scale 1.0 with height 1.0, that means y = 0.5.
	# But we control height via scale.y, so this offset scales with it.
	mesh_instance.position = Vector3(0, 0.5, 0)
	
	# Start invisible
	mesh_instance.scale = Vector3.ZERO
	
	# --- Build the hierarchy: PlantInstance -> pivot -> mesh ---
	add_child(pivot)
	pivot.add_child(mesh_instance)
	
	# --- Position the pivot randomly within the spawn radius ---
	var angle = randf() * TAU
	var distance = randf() * stem_def.spawn_radius
	var offset_x = cos(angle) * distance
	var offset_z = sin(angle) * distance
	pivot.position = Vector3(offset_x, 0.0, offset_z)
	
	return {
		"pivot": pivot,
		"mesh": mesh_instance,
		"target_height": target_height,
		"offset_x": offset_x,
		"offset_z": offset_z
	}


func _build_leaves() -> void:
	var leaf_def = plant_def.leaf_definition
	if leaf_def == null:
		return
	
	if leaf_def.shape.size() < 3:
		push_warning("Leaf shape need at least 3 points to form a polygon!")
		return
	
	for stem_index in range(stem_data.size()):
		for leaf_index in range(leaf_def.leaf_count_per_stem):
			var leaf = _create_single_leaf(leaf_def, stem_index, leaf_index)
			leaf_data.append(leaf)

func _create_single_leaf(leaf_def: LeafDefinition, stem_index: int, leaf_index: int) -> Dictionary:
	var stem = stem_data[stem_index]
	var target_height: float = stem["target_height"]
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = _build_leaf_mesh(leaf_def.shape)
	
	var material = StandardMaterial3D.new()
	material.albedo_color = leaf_def.color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	
	var height_ratio = randf_range(leaf_def.min_height_ratio, leaf_def.max_height_ratio)
	var leaf_y = height_ratio * target_height
	
	var count = leaf_def.leaf_count_per_stem
	var base_y_rotation = (float(leaf_index) / float(count)) * 360.0
	var rotation_deg = leaf_def.base_rotation + Vector3(
		randf_range(-leaf_def.rotation_randomness, leaf_def.rotation_randomness),
		base_y_rotation + randf_range(-leaf_def.rotation_randomness, leaf_def.rotation_randomness),
		randf_range(-leaf_def.rotation_randomness, leaf_def.rotation_randomness)
	)
	
	var scale_variation = randf_range(-leaf_def.scale_randomness, leaf_def.scale_randomness)
	var leaf_scale = leaf_def.base_scale * (1.0 + scale_variation)
	
	mesh_instance.scale = Vector3.ZERO
	
	stem["pivot"].add_child(mesh_instance)
	mesh_instance.position = Vector3(0.0, 0.0, 0.0)
	mesh_instance.rotation_degrees = rotation_deg
	
	return {
		"mesh": mesh_instance,
		"stem_index": stem_index,
		"target_scale": leaf_scale,
		"height_ratio": height_ratio
	}

func _build_leaf_mesh(shape_points: Array[Vector2]) -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	
	for i in range(1, shape_points.size() -1):
		var p0 = shape_points[0]
		var p1 = shape_points[i]
		var p2 = shape_points[i + 1]
	
		vertices.append(Vector3(p0.x, p0.y, 0))
		vertices.append(Vector3(p1.x, p1.y, 0))
		vertices.append(Vector3(p2.x, p2.y, 0))
		
		normals.append(Vector3.BACK)
		normals.append(Vector3.BACK)
		normals.append(Vector3.BACK)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	
	if vertices.size() >= 3:
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	else:
		push_warning("Leaf mesh has too few vertices to build!")
	return mesh

func _build_fruit() -> void:
	var fruit_def = plant_def.fruit_definition
	if fruit_def == null:
		return
	
	for stem_index in range(stem_data.size()):
		for fruit_index in range(fruit_def.fruit_count_per_stem):
			var fruit = _create_single_fruit(fruit_def, stem_index)
			fruit_data.append(fruit)

func _create_single_fruit(fruit_def: FruitDefinition, stem_index: int) -> Dictionary:
	var stem = stem_data[stem_index]
	var target_height: float = stem["target_height"]
	
	var mesh_instance = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	mesh_instance.mesh = sphere
	
	var material = StandardMaterial3D.new()
	material.albedo_color = fruit_def.color
	mesh_instance.material_override = material
	
	mesh_instance.scale = fruit_def.scale
	
	var fruit_y = fruit_def.position_on_stem * target_height
	
	var random_offset = Vector3(
		randf_range(-fruit_def.position_randomness, fruit_def.position_randomness),
		randf_range(-fruit_def.position_randomness, fruit_def.position_randomness),
		randf_range(-fruit_def.position_randomness, fruit_def.position_randomness)
	)
	
	stem["pivot"].add_child(mesh_instance)
	mesh_instance.position = Vector3(0.0, fruit_y, 0.0) + random_offset

	
	mesh_instance.visible = false
	
	return {
		"mesh": mesh_instance,
		"target_scale": fruit_def.scale,
		"stem_index": stem_index,
		"fruit_y": fruit_y,
		"random_offset": random_offset
	}

func update_growth(progress: float, duration: float = 0.5) -> void:
	if progress == growth_progress:
		return
	growth_progress = progress
	_current_turn_duration = duration
	var curve_value = progress
	if plant_def.growth_curve != null:
		curve_value = plant_def.growth_curve.sample(progress)
	
	_update_stems(curve_value, duration)
	
	_update_leaves(curve_value, duration)
		
	_update_fruit_visibility()

func _update_stems(curve_value: float, duration: float) -> void:
	for stem in stem_data:
		var mesh: MeshInstance3D = stem["mesh"]
		var target_height: float = stem["target_height"]
		
		var current_height = target_height * curve_value
		var new_scale = Vector3(curve_value, current_height, curve_value)
		
		var tween = create_tween()
		tween.tween_property(mesh, "scale", new_scale, duration)

func _update_leaves(curve_value: float, duration: float) -> void:
	for leaf in leaf_data:
		var mesh: MeshInstance3D = leaf["mesh"]
		var target_scale: Vector3 = leaf["target_scale"]
		var height_ratio: float = leaf["height_ratio"]
		var stem = stem_data[leaf["stem_index"]]
		var target_height: float = stem["target_height"]

		var current_height = target_height * curve_value
		var leaf_y = height_ratio * current_height
		var new_scale = target_scale * curve_value
		var new_pos = Vector3(0.0, leaf_y, 0.0)
		
		var tween = create_tween()
		tween.tween_property(mesh, "scale", new_scale, duration)
		tween.parallel().tween_property(mesh, "position", new_pos, duration)

func _update_fruit_visibility() -> void:
	var should_show = growth_progress >= 1.0
	for fruit in fruit_data:
		if should_show and not fruit["mesh"].visible:
			var mesh: MeshInstance3D = fruit["mesh"]
			var target_scale: Vector3 = fruit["target_scale"]
			
			mesh.visible = true
			mesh.scale = Vector3.ZERO
			
			# Wait for the turn animation to finish + 12% anticipation pause
			var fruit_delay = _current_turn_duration * 1.12
			var tween = create_tween()
			tween.tween_interval(fruit_delay)
			
			# Explode to 1.8x the final size, then bounce back down
			var overshoot_scale = target_scale * 1.8
			# Step 1: Explode from zero to overshoot (fast and punchy)
			tween.tween_property(mesh, "scale", overshoot_scale, 0.15)\
				.set_ease(Tween.EASE_OUT)\
				.set_trans(Tween.TRANS_BACK)
			# Step 2: Slam back down to actual size with elastic wobble
			tween.tween_property(mesh, "scale", target_scale, 0.35)\
				.set_ease(Tween.EASE_OUT)\
				.set_trans(Tween.TRANS_ELASTIC)
			# Temporarily disable wind sway so it doesn't fight the shake
			_sway_enabled = false
			# Step 3: Shake the stem to simulate the weight of fruit appearing
			var stem = stem_data[fruit["stem_index"]]
			var stem_pivot: Node3D = stem["pivot"]
			var shake_tween = create_tween()
			# Wait the same amount before shaking (match the fruit pop timing)
			shake_tween.tween_interval(fruit_delay)
			# Wobble the stem back and forth, getting smaller each time
			shake_tween.tween_property(stem_pivot, "rotation_degrees", Vector3(8, 0, 6), 0.08)
			shake_tween.tween_property(stem_pivot, "rotation_degrees", Vector3(-6, 0, -4), 0.08)
			shake_tween.tween_property(stem_pivot, "rotation_degrees", Vector3(4, 0, 3), 0.07)
			shake_tween.tween_property(stem_pivot, "rotation_degrees", Vector3(-2, 0, -1), 0.07)
			shake_tween.tween_property(stem_pivot, "rotation_degrees", Vector3.ZERO, 0.1)
			shake_tween.tween_callback(func(): _sway_enabled = true)
			
		elif not should_show and fruit["mesh"].visible:
			fruit["mesh"].visible = false
