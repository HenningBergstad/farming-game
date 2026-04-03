extends PanelContainer

var crop_data: CropData = null
var seed_name: Label = null
var seed_price: Label = null

signal seed_picked(crop_data)

func _ready() -> void:
	seed_name = $VBoxContainer/SeedName
	seed_price = $VBoxContainer/SeedPrice

func setup(setup_crop_data: CropData) -> void:
	crop_data = setup_crop_data
	seed_name.text = setup_crop_data.name
	seed_price.text = str(setup_crop_data.buy_price)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		seed_picked.emit(crop_data)
