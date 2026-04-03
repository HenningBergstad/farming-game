extends Control

const PEEK_AMOUNT: float = 150.0
var closed_pos_Y: float
var peek_pos_y: float
var open_pos_y: float
var sell_zone_size: float = 500.0

var active_tween: Tween = null

func _ready() -> void:
	closed_pos_Y = position.y
	peek_pos_y = position.y - PEEK_AMOUNT
	open_pos_y = position.y - sell_zone_size

func peek() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(self, "position", Vector2(position.x, peek_pos_y), 0.2).set_ease(Tween.EASE_IN)

func open() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(self, "position", Vector2(position.x, open_pos_y), 0.2).set_ease(Tween.EASE_IN)

func close() -> void:
	if active_tween and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(self, "position", Vector2(position.x, closed_pos_Y), 0.3).set_ease(Tween.EASE_IN)

func is_mouse_in_sell_zone() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	return $MarginContainer2/SellZone.get_global_rect().has_point(mouse_pos)
