extends PlantBase

@onready var sub_plants = get_children().filter(func(child): return child is Node3D)
var plant_data: Array = []
var stem_height: float = 1.92
var randpos_scale: float = 0.3

func _build_plant() -> void:
	for plant in sub_plants:
		var stalk_container = plant.get_node("Stalk")
		var leaves_container = plant.get_node("Leaves")
		
		# 1 Random placement
		var x_displacement = randf_range(-randpos_scale, randpos_scale)
		var z_displacement = randf_range(-randpos_scale, randpos_scale)
		var r_displacement = randf_range(0, TAU)
		plant.position = Vector3(x_displacement, 0, z_displacement)
		plant.rotation.y = r_displacement
		
		# 2 Pick a height scale
		var height_scale = randf_range(0.9, 1.1)
		
		# 3 Scale stalk to zero
		for stalk in stalk_container.get_children():
			stalk.scale = Vector3(1.0, 1.0, 0.0)
		
		# 4 Process leaves 
		var leaf_entries: Array = []
		for leaf in leaves_container.get_children():
			leaf.position.y += randf_range(-0.05, 0.05)
			
			var height_ratio = clamp(leaf.position.y / stem_height, 0.0, 1.0)
			
			var target_scale = leaf.scale
			leaf.scale = Vector3.ZERO
			
			leaf_entries.append({
				"node": leaf,
				"height_ratio": height_ratio,
				"target_scale": target_scale
			})
		
		# 5 Process fruit
		var fruit_point = plant.get_node("FruitPoint")
		var fruit_point_original_y = fruit_point.position.y
		fruit_point.position.y = 0.0
		var fruit_entries: Array = []
		var beige = Color(0.927, 0.91, 0.82, 1.0)
		for fruit_mesh in fruit_point.get_children():
			var target_scale = fruit_mesh.scale
			fruit_mesh.scale = Vector3.ZERO
			# Set initial colour to beige
			var mat = fruit_mesh.get_active_material(0)
			if mat is ShaderMaterial:
				mat.set_shader_parameter("color_ting", Vector3(beige.r, beige.g, beige.b))
			fruit_entries.append({
				"node": fruit_mesh,
				"target_scale": target_scale,
				"material": mat
			})
		
		# 6 Store plant data
		plant_data.append({
			"node": plant,
			"height_scale": height_scale,
			"stalk_container": stalk_container,
			"leaves": leaf_entries,
			"fruits": fruit_entries,
			"fruit_point": fruit_point,
			"fruit_point_original_y": fruit_point_original_y
		})

func _apply_growth(curve_value: float, duration: float) -> void:
	for data in plant_data:
		var height_scale = data["height_scale"]
		var stalk_container = data["stalk_container"]
		
		# 1 Grow stalks
		var stalk_target = Vector3(1.0, 1.0, curve_value * height_scale)
		for stalk in stalk_container.get_children():
			var tween = create_tween()
			tween.tween_property(stalk, "scale", stalk_target, duration)
		
		# 2 Grow leaves
		for leaf_entry in data["leaves"]:
			var leaf_node = leaf_entry["node"]
			var height_ratio = leaf_entry["height_ratio"]
			var target_scale = leaf_entry["target_scale"]
			
			var leaf_progress = clamp((curve_value - height_ratio) / (1.0 - height_ratio), 0.0, 1.0)
			if leaf_progress > 0.0:
				leaf_progress = max(leaf_progress, 0.3)
			var leaf_target = target_scale * leaf_progress
			
			var tween = create_tween()
			tween.tween_property(leaf_node, "scale", leaf_target, duration)
		
		# 3 Grow fruit
		var fruit_threshold = 0.7
			# Move fruit point with stem growth
		var fruit_point = data["fruit_point"]
		var fruit_point_y = data["fruit_point_original_y"]
		var tween_fp = create_tween()
		tween_fp.tween_property(fruit_point, "position:y", fruit_point_y * curve_value * height_scale, duration) 
			# Grow the fruit
		for fruit_entry in data["fruits"]:
			var fruit_node = fruit_entry["node"]
			var target_scale = fruit_entry["target_scale"]
			var mat = fruit_entry["material"]
			
			var fruit_progress = clamp((curve_value - fruit_threshold) / (1.0 - fruit_threshold), 0.0, 1.0)
			
			# Scale
			var fruit_target = target_scale * fruit_progress
			var tween = create_tween()
			tween.tween_property(fruit_node, "scale", fruit_target, duration)
			
			# Colour: lerp from beige to white
			var beige = Vector3(0.95, 0.9, 0.7)
			var white = Vector3(1.0, 1.0, 1.0)
			var tint = beige.lerp(white, fruit_progress)
			if mat is ShaderMaterial:
				mat.set_shader_parameter("color_tint", tint)
