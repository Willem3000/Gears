extends Panel

class_name InventorySlot

signal updated_slot

@export var held_item: InventoryItem:
	set(value):
		held_item = value
		if held_item == null:
			find_child("TextureRect").texture = null
		else:
			var texture_rect = find_child("TextureRect")
			if texture_rect != null:
				texture_rect.texture = held_item.icon

func _ready():
	held_item = held_item
	update_quantity()

func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == 1:
		SignalManager.selected_inventory_slot.emit(self)
	
	if event is InputEventMouseMotion:
		$ItemDescription.global_position = get_global_mouse_position()
		
func swap_out(new_item: InventoryItem) -> InventoryItem:
	if held_item != null && new_item != null:
		if held_item.item_name == new_item.item_name:
			append_item(new_item)
			return null
	
	var held_item_buffer = held_item
	remove_stack()

	if new_item != null:
		add_item(new_item)

	return held_item_buffer

func add_item(item: InventoryItem):
	held_item = item.duplicate()
	update_quantity()

func append_item(item: InventoryItem):
	held_item.quantity += item.quantity
	update_quantity()

func remove_stack():
	held_item = null
	update_quantity()
	
func update_quantity():
	if held_item != null:
		if held_item.quantity > 0:
			find_child("Label").text = str(held_item.quantity)
		else:
			remove_stack()
	else:
		find_child("Label").text = ""
	
	updated_slot.emit()

func _on_mouse_exited():
	$ItemDescription.visible = false


func _on_mouse_entered():
	if held_item != null:
		$ItemDescription.visible = true
		$ItemDescription.clear()
		$ItemDescription.size = Vector2($ItemDescription.size.x,0)
		$ItemDescription.add_item(held_item.item_name)
