extends PlantBase

@onready var bushes = get_children().filter(func(child): return child is Node3D)
var plant_data: Array = []

func _build_plant() -> void:
	for bush in bushes:
		var stalk_container = bush.get_node("Stalk")
		var leaves_container = bush.get_node("Leaves")
		
		# 1 Random 
		var ry_displacement = randf_range(0, TAU)
		var rx_displacement = randf_range(0, TAU/10.0)
		var rz_displacement = randf_range(0, TAU/10.0)
		
		bush.rotation.y = ry_displacement
		bush.rotation.x = rx_displacement
		bush.rotation.z = rz_displacement
	
		# 2 Pick a height scale
		var height_scale = randf_range(0.9, 1.1)
		
		# 3 Scale stalk to zero
		for stalk in stalk_container.get_children():
			stalk.scale = Vector3(1.0, 1.0, 0.0)
		
		# 4 Process leaves 
		var leaf_entries: Array = []
		for leaf in leaves_container.get_children():
			leaf.position.y += randf_range(-0.01, 0.01)
			
			var target_scale = leaf.scale
			leaf.scale = Vector3.ZERO
			
			leaf_entries.append({
				"node": leaf,
				"target_scale": target_scale
			})
		
		# 6 Store plant data
		plant_data.append({
			"node": bush,
			"height_scale": height_scale,
			"stalk_container": stalk_container,
			"leaves": leaf_entries,
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
			var target_scale = leaf_entry["target_scale"]
			
			var leaf_progress = curve_value
			if leaf_progress > 0.0:
				leaf_progress = max(leaf_progress, 0.2)
			var leaf_target = target_scale * leaf_progress
			
			var tween = create_tween()
			tween.tween_property(leaf_node, "scale", leaf_target, duration)
