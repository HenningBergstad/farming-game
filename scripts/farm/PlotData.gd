class_name PlotData
extends Resource

var soil_quality: int = 0
var soil_fertility: int = 0
var microbial_activity: int = 0

var persistence: float = 0.0
var hollow_yield: float = 0.0

var crop_data: CropData = null
var turns_remaining: int = 0
var price_bonus: float = 0.0


# Check if plot is occupied and return true or false
func is_occupied() -> bool:
	return crop_data != null

func is_ready_to_harvest() -> bool:
	return is_occupied() and turns_remaining <= 0
	
func plant(new_crop: CropData, bonus: float = 0.0) -> void:
	crop_data = new_crop
	turns_remaining = new_crop.base_growth_time
	price_bonus = bonus

func advance_turn() -> void:
	if is_occupied() and not is_ready_to_harvest():
		var fertility_modifier = soil_fertility * 0.1
		turns_remaining = max(0, turns_remaining - 1 - fertility_modifier)

func harvest() -> bool:
	if not is_ready_to_harvest():
		print("Crop is not ready to harvest")
		return false
	
	apply_soil_effects()
	var persists = randf() < persistence
	if persists:
		turns_remaining = crop_data.base_growth_time
	else:
		crop_data = null
		turns_remaining = 0
		price_bonus = 0.0
	return persists

func apply_soil_effects() -> void:
	if crop_data == null:
		return
	var microbial_multiplier = 1.0 + (microbial_activity * 0.1)
	soil_quality += int(crop_data.soil_quality_effect * microbial_multiplier)
	soil_fertility += int(crop_data.soil_quality_effect * microbial_multiplier)
	microbial_activity += crop_data.microbial_activity_effect
	persistence += crop_data.persistence_change
	hollow_yield += crop_data.hollow_yield_change
	
	soil_quality = clamp(soil_quality, -10, 10)
	soil_fertility = clamp(soil_fertility, -10, 10)
	microbial_activity = clamp(microbial_activity, -10, 10)
	persistence = clamp(persistence, 0.0, 1.0)
	hollow_yield = clamp(hollow_yield, 0.0, 1.0)

func get_stage() -> String:
	if not is_occupied():
		return ""
	if turns_remaining == 0:
		return "ready"
	if turns_remaining == crop_data.base_growth_time:
		return "planted"
	return "growing"
