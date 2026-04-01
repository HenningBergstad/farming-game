extends Node

signal market_updated

var market_data = {
	# Tracks necessary information about the current market in this format:
	# "crop": { "supply": 0.3, "pending_supply": 0.0, "frozen_turns": 0 }
}

func record_sale(crop_data: CropData) -> void:
	if not market_data.has(crop_data.name):
		market_data[crop_data.name] = {"supply": 0.0, "pending_supply": 0.0, "frozen_turns": 0 }
	
	market_data[crop_data.name]["pending_supply"] += GameConfig.MARKET_SATURATION_HIT * (1.0 - crop_data.market_resilience)
	market_data[crop_data.name]["frozen_turns"] = GameConfig.MARKET_FREEZE

func get_sell_price(crop_data: CropData, price_bonus: float) -> int:
	var base_price = crop_data.base_price
	
	if not market_data.has(crop_data.name):
		return base_price
	
	var min_sell_price = GameConfig.MIN_SELL_PRICE
	var supply = market_data[crop_data.name]["supply"]
	
	var sell_price = base_price - (base_price * supply) + price_bonus
	
	if sell_price < min_sell_price:
		sell_price = min_sell_price
	
	return sell_price

func advance_turn() -> void:
	for entry in market_data:
		market_data[entry]["supply"] += market_data[entry]["pending_supply"]
		market_data[entry]["pending_supply"] = 0
		
		if market_data[entry]["frozen_turns"] > 0:
			market_data[entry]["frozen_turns"] -= 1
			continue
		
		if market_data[entry]["supply"] > 0:
			market_data[entry]["supply"] -= GameConfig.MARKET_RECOVERY_RATE
			if market_data[entry]["supply"] < 0:
				market_data[entry]["supply"] = 0
	
	market_updated.emit()
