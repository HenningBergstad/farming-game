extends PanelContainer

func show_plot(plot: PlotData, mouse_pos: Vector2) -> void:
	if plot.is_occupied():
		$VBoxContainer/CropLabel.text = plot.crop_data.name + " (" + str(plot.turns_remaining) + " turns left)"
	else:
		$VBoxContainer/CropLabel.text = "Empty"
	
	# Set soil stats
	$VBoxContainer/SoilQualityLabel.text = "Soil quality:       " + str(plot.soil_quality)
	$VBoxContainer/SoilFertilityLabel.text = "Soil fertility:        " + str(plot.soil_fertility)
	$VBoxContainer/MicrobialLabel.text = "Microbial activity: " + str(plot.microbial_activity)
	
	# Set unipolar modifiers
	$VBoxContainer/PersistenceLabel.text = "Persistence chance:       " + "%.2f" % plot.persistence
	$VBoxContainer/HollowYieldLabel.text = "Hollow yield chance:      " + "%.2f" % plot.hollow_yield
	
	# Position the panel at the mouse, nudged slightly up and to the left
	position = mouse_pos # - Vector2(20, 30)
	
	show()

func close() -> void:
	hide()
