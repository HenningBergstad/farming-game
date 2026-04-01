extends Node

var player_gold: int = GameConfig.STARTING_GOLD

signal gold_changed(new_amount)

func spend(amount: int) -> bool:
	if player_gold - amount >= 0:
		player_gold -= amount
		gold_changed.emit(player_gold)
		return true
	
	return false

func earn(amount: int) -> void:
	player_gold += amount
	gold_changed.emit(player_gold)
