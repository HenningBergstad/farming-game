class_name LeafDefinition
extends Resource

## Blueprint for leaves on a plant. Defines what they look like and the rules
## for how they attach to stems. Each plant type has one LeafDefinition that
## applies to all of its stems.

## --- PLACEMENT RULES ---

## How many leaves grow on each stem.
## A corn stalk might have 4-6, a small herb might have 2-3.
@export var leaf_count_per_stem: int = 4

## The lowest point on the stem where a leaf can appear.
## 0.0 = the very base of the stem, 1.0 = the very top.
## Example: 0.3 means leaves only grow on the upper 70% of the stem.
@export_range(0.0, 1.0) var min_height_ratio: float = 0.2

## The highest point on the stem where a leaf can appear.
## Leaves are randomly distributed between min_height_ratio and max_height_ratio.
@export_range(0.0, 1.0) var max_height_ratio: float = 0.9

## --- SIZE ---

## Base size of each leaf. X = width, Y = height (length of the leaf), Z = depth.
## Since leaves are flat polygons, Z will typically be small (like 1.0).
@export var base_scale: Vector3 = Vector3(0.15, 0.2, 1.0)

## How much each leaf's size can randomly vary.
## 0.0 = all leaves are exactly base_scale
## 0.3 = leaves can be ±30% of base_scale
@export_range(0.0, 1.0) var scale_randomness: float = 0.1

## --- ROTATION ---

## The starting rotation of leaves in degrees.
## Leaves typically point outward from the stem, so you'd set this to
## angle them away. The Y rotation is randomized per-leaf to spread
## them around the stem (like a spiral or whorl pattern).
@export var base_rotation: Vector3 = Vector3(0.0, 0.0, -45.0)

## How much each leaf's rotation can randomly vary (in degrees).
## Adds organic imperfection so leaves don't look too uniform.
@export var rotation_randomness: float = 15.0

## --- APPEARANCE ---

## The color of the leaves.
@export var color: Color = Color(0.1, 0.6, 0.15)

## The 2D outline points that define the leaf's shape.
## These points form a flat polygon mesh. The leaf is built in the XY plane
## and then rotated into position on the stem.
##
## Example — a simple pointed leaf:
##   [Vector2(0, 0), Vector2(0.3, 0.5), Vector2(0, 1), Vector2(-0.3, 0.5)]
##
## The points should form a closed shape (the code connects the last point
## back to the first automatically).
@export var shape: Array[Vector2] = [
	Vector2(0.0, 0.0),
	Vector2(0.3, 0.5),
	Vector2(0.0, 1.0),
	Vector2(-0.3, 0.5)
]
