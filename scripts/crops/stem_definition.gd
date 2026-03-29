class_name StemDefinition
extends Resource

@export var max_height: float = 1.0
@export var max_thickness: float = 0.05
@export var min_start_scale: float = 0.0
@export var position_offset: Vector3 = Vector3.ZERO
@export var random_offset_range: float = 0.0
@export var follow_path: bool = false
@export var path_curve: Curve3D = null
@export var leaves: Array[LeafDefinition] = []
