extends CanvasLayer

var player_gold: int = PlayerData.player_gold

signal next_turn_pressed

func _ready() -> void:
	$SellDrawerContainer/HBoxContainer/MarginContainer3/Button.pressed.connect(_on_next_turn_pressed)
	$PlotInfoPanel.hide()
	$BuyDrawerContainer/HBoxContainer/MarginContainer/GoldPanel/GoldLabel.text = str(player_gold)
	PlayerData.gold_changed.connect(update_gold_label)

func _on_next_turn_pressed() -> void:
	close_plot_info()
	next_turn_pressed.emit()

func show_plot_info(plot: PlotData, mouse_pos: Vector2) -> void:
	$PlotInfoPanel.show_plot(plot, mouse_pos)
	
func close_plot_info() -> void:
	$PlotInfoPanel.close()

func update_gold_label(amount) -> void:
	$BuyDrawerContainer/HBoxContainer/MarginContainer/GoldPanel/GoldLabel.text = str(amount)
