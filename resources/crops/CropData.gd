class_name CropData
extends Resource

## The display name of the crop
@export var name: String = ""

## Purchase price in the store
@export var buy_price: int = 0

## Base sell price at the farmer's market
@export var base_price: int = 0

## How resistant this crop is to market price drops (0.0 = no resistance, 1.0 = fully resistant)
@export_range(0.0, 1.0) var market_resilience: float = 0.0

## How many turns this crop takes to mature
@export var base_growth_time: int = 1

## Soil Quality change applied upon harvest (-10 to +10)
@export_range(-10, 10) var soil_quality_effect: int = 0

## Soil Fertility change applied upon harvest (-10 to +10)
@export_range(-10, 10) var soil_fertility_effect: int = 0

## Microbial Activity change applied upon harvest (-10 to +10)
@export_range(-10, 10) var microbial_activity_effect: int = 0

## How much this crop raises or lowers the Persistence probability (-1.0 to +1.0)
@export_range(-1.0, 1.0) var persistence_change: float = 0.0

## How much this crop raises or lowers the Hollow Yield probability (-1.0 to +1.0)
@export_range(-1.0, 1.0) var hollow_yield_change: float = 0.0

@export var model_folder: String = "res://models/crops/"

@export var plant_definition: PlantDefinition = null
