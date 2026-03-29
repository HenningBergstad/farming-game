extends CanvasLayer

signal next_turn_pressed

func _ready() -> void:
	$Button.pressed.connect(_on_next_turn_pressed)
	$PlotInfoPanel.hide()

func _on_next_turn_pressed() -> void:
	close_plot_info()
	next_turn_pressed.emit()

func show_plot_info(plot: PlotData, mouse_pos: Vector2) -> void:
	$PlotInfoPanel.show_plot(plot, mouse_pos)

func close_plot_info() -> void:
	$PlotInfoPanel.close()
