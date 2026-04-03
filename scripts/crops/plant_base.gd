extends Node3D
class_name PlantBase

var growth_progress: float
var wind_direction: float
var wind_strength: float
var plot_data: PlotData

var _all_meshes: Array = []

func setup(plot_data: PlotData) -> void:
	self.plot_data = plot_data
	_build_plant()
	_collect_meshes(self)

func update_growth(progress: float, duration: float) -> void:
	growth_progress = progress
	_apply_growth(progress, duration)

func set_wind(angle: float, strength: float, speed: float, duration: float) -> void:
	wind_direction = angle
	wind_strength = strength
	var direction_vec = Vector2(cos(angle), sin(angle))
	for mesh in _all_meshes:
		var mat = mesh.get_active_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("wind_direction", direction_vec)
			mat.set_shader_parameter("wind_strength", strength)
			mat.set_shader_parameter("wind_speed", speed)

func _build_plant() -> void:
	pass

func _apply_growth(curve_value: float, duration: float) -> void:
	pass

func _set_shader_param(node: MeshInstance3D, param: String, value) -> void:
	pass

func _jitter_rotation(node: Node3D, degrees: float) -> void:
	pass

func _jitter_scale(node: Node3D, amount: float) -> void:
	pass

func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			_all_meshes.append(child)
		_collect_meshes(child)
