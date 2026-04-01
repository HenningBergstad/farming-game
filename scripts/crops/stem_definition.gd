class_name StemDefinition
extends Resource

## Blueprint for a single stem. The PlantDefinition will spawn multiple copies
## of this, each with randomized position and height variation.

## How thick the stem cylinder is (radius in Godot units).
## Corn might be ~0.06, a thin herb might be ~0.02.
@export var thickness: float = 0.05

## How far from the center of the plot a stem can spawn.
## The actual position is randomized within a circle of this radius.
## 0.0 = all stems spawn dead center, 0.3 = stems spread out across the plot.
@export var spawn_radius: float = 0.1

## The color of the stem.
@export var color: Color = Color(0.2, 0.5, 0.1)

## If true, the stem grows along a curved path instead of straight up.
## Useful for plants that bend or lean (e.g. a vine or a wilting flower).
@export var follow_path: bool = false

## The 3D curve the stem follows when follow_path is true.
## Ignored if follow_path is false.
@export var path_curve: Curve3D = null
