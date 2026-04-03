extends Node3D

var plot_data: PlotData = null
var plant: PlantBase = null

func setup(plot: PlotData, world_position: Vector3) -> void:
	plot_data = plot
	position = world_position
	
	if plot.crop_data.plant_scene == null:
		return
	
	plant = plot.crop_data.plant_scene.instantiate()
	add_child(plant)
	plant.setup(plot)
	plant.update_growth(0.0, 0.0)

func update_visual(progress: float, duration: float = 0.5) -> void:
	if plant == null:
		return
	plant.update_growth(progress, duration)

func set_wind(angle: float, strength: float, speed: float) -> void:
	if plant == null:
		return
	plant.set_wind(angle, strength, speed)
