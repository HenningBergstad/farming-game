extends PanelContainer


var label = Label

func _ready() -> void:
	label = $Label

func setup(crop_name: String) -> void:
	label.text = crop_name
