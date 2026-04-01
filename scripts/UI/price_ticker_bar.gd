extends HBoxContainer

var card_scene = preload("res://scenes/UI/crop_card.tscn")
var card_list = {}

func _ready() -> void:
	for crop_path in GameConfig.CROP_PATHS:
		var crop_data = load(crop_path)
		var instance = card_scene.instantiate()
		instance.setup(crop_data)
		add_child(instance)
		card_list[str(crop_data.name)] = instance
	
	MarketManager.market_updated.connect(update_prices)

func update_prices() -> void:
	for card in card_list:
		card_list[card].update_price()
