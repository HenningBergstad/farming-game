class_name PlantInstance
extends Node3D

var plot_data: PlotData = null
var plant_def: PlantDefinition = null
var growth_progress: float = 0.0

var stem_instances: Array = []

func setup(plot: PlotData) -> void:
	plot_data = plot
	plant_def = plot.crop_data.plant_definition
	if plant_def == null:
		print("No plant definition found for: ", plot.crop_data.name)
		return
	_build_plant()

func _build_plant():
	# Clear any existing stems
	for child in get_children():
		child.queue_free()
	stem_instances = []
	
	# Build each stem
	for stem_def in plant_def.stems:
		var stem = _build_stem(stem_def)
		stem_instances.append(stem)

func _build_stem(stem_def: StemDefinition) -> MeshInstance3D:
	var stem = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = stem_def.max_thickness * 0.5
	mesh.bottom_radius = stem_def.max_thickness
	mesh.height = stem_def.max_height
	stem.mesh = mesh
	stem.scale = Vector3.ZERO
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.5, 0.1)
	stem.material_override = material
	
	# Position after adding to scene tree
	add_child(stem)
	stem.position = stem_def.position_offset + Vector3(
		randf_range(-stem_def.random_offset_range, stem_def.random_offset_range),
		stem_def.max_height * 0.5,
		randf_range(-stem_def.random_offset_range, stem_def.random_offset_range)
	)
	
	return stem

func update_growth(progress: float) -> void:
	growth_progress = progress
	
	var curve_value = 1.0
	if plant_def.growth_curve != null:
		curve_value = plant_def.growth_curve.sample(progress)
	
	for i in range(stem_instances.size()):
		var stem = stem_instances[i]
		var stem_def = plant_def.stems[i]
		var target_scale = lerp(stem_def.min_start_scale, 1.0, curve_value)
		
		# Tween to the new scale smoothly instead of jumping
		var tween = create_tween()
		tween.tween_property(stem, "scale", Vector3(target_scale, target_scale, target_scale), 0.5)
