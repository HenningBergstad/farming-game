extends Node3D

var plot_data: PlotData = null
var plant_instance: PlantInstance = null

func setup(plot: PlotData, world_position: Vector3) -> void:
	plot_data = plot
	position = world_position

	# Create the plant instance
	plant_instance = PlantInstance.new()
	add_child(plant_instance)
	plant_instance.setup(plot_data)
	
	# Start at zero growth
	plant_instance.update_growth(0.0)

func update_visual(progress: float, duration: float = 0.5) -> void:
	if plant_instance != null:
		plant_instance.update_growth(progress, duration)


func set_wind(angle: float, duration: float = 0.5) -> void:
	if plant_instance != null:
		plant_instance.set_wind(angle, duration)
