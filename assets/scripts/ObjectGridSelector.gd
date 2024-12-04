extends Control

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == 1:
			if Input.is_action_pressed("shift"):
				SignalManager.shift_selected_object_grid.emit()
			else:
				SignalManager.selected_object_grid.emit()
		
		SignalManager.hover_object_grid.emit()
