extends PlantBase

@onready var sub_plants = get_children().filter(func(child): return child is Node3D)
var plant_data: Array = []
var stem_height: float = 1.92

func _build_plant() -> void:
	for plant in sub_plants:
		var stalk_container = plant.get_node("Stalk")
		var leaves_container = plant.get_node("Leaves")
		
		# 1 Random placement
		var x_displacement = randf_range(-0.4, 0.4)
		var z_displacement = randf_range(-0.4, 0.4)
		var r_displacement = randf_range(0, TAU)
		plant.position = Vector3(x_displacement, 0, z_displacement)
		plant.rotation.y = r_displacement
		
		# 2 Pick a height scale
		var height_scale = randf_range(0.9, 1.1)
		
		# 3 Scale stalk to zero
		for stalk in stalk_container.get_children():
			stalk.scale = Vector3.ZERO
		
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
		
		# 5 Store plant data
		plant_data.append({
			"node": plant,
			"height_scale": height_scale,
			"stalk_container": stalk_container,
			"leaves": leaf_entries
		})

func _apply_growth(curve_value: float, duration: float) -> void:
	for data in plant_data:
		var height_scale = data["height_scale"]
		var stalk_container = data["stalk_container"]
		
		# 1 Grow stalks
		var stalk_target = Vector3(curve_value, curve_value * height_scale, curve_value)
		for stalk in stalk_container.get_children():
			var tween = create_tween()
			tween.tween_property(stalk, "scale", stalk_target, duration)
		
		for leaf_entry in data["leaves"]:
			var leaf_node = leaf_entry["node"]
			var height_ratio = leaf_entry["height_ratio"]
			var target_scale = leaf_entry["target_scale"]
			
			var leaf_progress = clamp((curve_value - height_ratio) / (1.0 - height_ratio), 0.0, 1.0)
			var leaf_target = target_scale * leaf_progress
			
			var tween = create_tween()
			tween.tween_property(leaf_node, "scale", leaf_target, duration)
		
		# 2 Grow leaves
