class_name PlantDefinition
extends Resource

## The master blueprint for how a plant looks when generated procedurally.
## Each crop type (corn, carrot, etc.) will have one of these.

## How tall the plant is when fully grown (in Godot units / meters).
## Each stem will aim for this height, with slight random variation.
@export var max_height: float = 1.0

## How much each stem's height can randomly vary from max_height.
## 0.0 = all stems are exactly max_height
## 0.1 = stems can be ±10% of max_height (e.g. 0.9 to 1.1 for a 1.0 max)
@export_range(0.0, 1.0) var height_randomness: float = 0.1

## How many stems this plant spawns on its plot.
## For example: corn might have 1-2, a bush might have 5-6.
@export var stem_count: int = 1

## The blueprint for each stem. All stems on this plant use the same template,
## but each one gets randomized position and slight height variation.
@export var stem_definition: StemDefinition = null

## The blueprint for leaves. Defines what the leaves look like and how they
## attach to stems. Set to null if this plant has no leaves.
@export var leaf_definition: LeafDefinition = null

## The blueprint for fruit. Fruit only appears when the plant is fully grown
## (growth progress = 1.0) as a visual "ready to harvest!" signal.
## Set to null if this plant has no fruit (e.g. clover, alfalfa).
@export var fruit_definition: FruitDefinition = null

## Controls how fast/slow the plant grows visually.
## X axis = growth progress (0.0 to 1.0)
## Y axis = visual scale multiplier (0.0 to 1.0)
## A linear curve = steady growth. An S-curve = slow start, fast middle, slow end.
@export var growth_curve: Curve = null
