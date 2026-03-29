class_name LeafDefinition
extends Resource

@export var position_on_stem: float = 0.5
@export var base_rotation: Vector3 = Vector3.ZERO
@export var random_rotation_range: float = 0.0
@export var base_scale: Vector3 = Vector3.ONE
@export var color: Color = Color.GREEN
# Leaf outline defined as a series of 2D points
# These will be used to build the leaf mesh in code
@export var shape: Array[Vector2] = []
