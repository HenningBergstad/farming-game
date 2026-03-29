class_name PlantDefinition
extends Resource

@export var stems: Array[StemDefinition] = []
@export var fruit: FruitDefinition = null
# Growth curve — controls how fast/slow growth accelerates
# X axis = growth progress (0.0 to 1.0)
# Y axis = scale multiplier (0.0 to 1.0)
@export var growth_curve: Curve = null
