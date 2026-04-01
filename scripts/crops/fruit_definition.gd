class_name FruitDefinition
extends Resource

## Blueprint for fruit that appears on a plant when it's fully grown.
## Fruit only pops into existence at growth progress = 1.0, acting as
## a visual "ready to harvest!" signal. Not all plants have fruit —
## set this to null on the PlantDefinition for plants like clover or alfalfa.

## --- PLACEMENT ---

## Where on the stem the fruit appears, as a ratio from base to top.
## 0.0 = the very base of the stem (weird, but possible for root vegetables?)
## 0.5 = halfway up the stem
## 1.0 = the very top of the stem (e.g. a sunflower head)
@export_range(0.0, 1.0) var position_on_stem: float = 0.8

## How many fruits appear on each stem.
## 1 for corn (one cob per stalk), maybe 3-5 for a tomato plant.
@export var fruit_count_per_stem: int = 1

## Random offset applied to each fruit's position (in Godot units).
## Keeps multiple fruits from stacking on top of each other.
## 0.0 = all fruits at the exact same spot, 0.1 = slight spread.
@export var position_randomness: float = 0.05

## --- APPEARANCE ---

## Size of the fruit mesh (a sphere).
## X, Y, Z let you make elongated shapes (e.g. a tall corn cob vs a round tomato).
@export var scale: Vector3 = Vector3(0.1, 0.1, 0.1)

## The color of the fruit.
@export var color: Color = Color(0.9, 0.8, 0.1)
