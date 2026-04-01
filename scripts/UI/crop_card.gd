extends PanelContainer

var crop_data: CropData = null

func setup(new_crop_data: CropData) -> void:
	crop_data = new_crop_data
	var crop_name = crop_data.name
	var price = MarketManager.get_sell_price(crop_data, 0.0)
	
	$VBoxContainer/Panel/CropNameLabel.text = crop_name
	$VBoxContainer/Panel/PriceLabel.text = str(price)

func update_price() -> void:
	$VBoxContainer/Panel/PriceLabel.text = str(MarketManager.get_sell_price(crop_data, 0.0))
