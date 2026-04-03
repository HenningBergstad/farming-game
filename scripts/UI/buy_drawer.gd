extends Control

const PEEK_AMOUNT: float = 150.0
var closed_pos_y: float
var open_pos_y: float
var buy_zone_size: float = 520.0

var card_scene = preload("res://scenes/UI/seed_card.tscn")

var active_tween: Tween = null

signal planting_started(crop_data)

func _ready() -> void:
	closed_pos_y = position.y
	open_pos_y = position.y + buy_zone_size
	for crop_path in GameConfig.CROP_PATHS:
		var crop_data = load(crop_path)
		var instance = card_scene.instantiate()
		$MarginContainer/MarginContainer/VBoxContainer/StoreRow.add_child(instance)
		instance.setup(crop_data)
		instance.seed_picked.connect(_on_seed_picked)

func open() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(self, "position", Vector2(position.x, open_pos_y), 0.2).set_ease(Tween.EASE_IN)

func close() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(self, "position", Vector2(position.x, closed_pos_y), 0.2).set_ease(Tween.EASE_IN)

func is_mouse_in_buy_zone() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	return $HBoxContainer.get_global_rect().has_point(mouse_pos)

func _on_seed_picked(crop_data: CropData) -> void:
	planting_started.emit(crop_data)
