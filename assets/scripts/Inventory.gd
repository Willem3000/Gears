extends Control

class_name Inventory

var is_open = false

func _ready():
	SignalManager.toggle_inventory.connect(toggle)
	SignalManager.add_to_inventory.connect(add_item)
	close()
	$AnimationPlayer.stop()


func toggle():
	if is_open:
		close()
	else:
		open()


func open():
	is_open = true
	$AnimationPlayer.stop()	
	$AnimationPlayer.speed_scale = 3
	$AnimationPlayer.play("OpenInventory")
	$AudioStreamPlayer.stream = load("res://assets/sound/sound_effects/InventoryOpen.wav")
	$AudioStreamPlayer.play()
	pass


func close():
	is_open = false
	$AnimationPlayer.speed_scale = 4	
	$AnimationPlayer.play_backwards("OpenInventory")
	$AudioStreamPlayer.stream = load("res://assets/sound/sound_effects/InventoryClose.wav")	
	$AudioStreamPlayer.play()
	pass


func add_item(item: InventoryItem):
	var empty_space: InventorySlot = null
	for panel: InventorySlot in $GridContainer.get_children():
		if empty_space == null and panel.held_item == null:
			empty_space = panel
		
		if panel.held_item != null && panel.held_item.item_name == item.item_name:
			panel.append_item(item)
			return
	
	if empty_space != null:
		empty_space.add_item(item)
		return
	
	print("Inventory full!")


func remove_item(item, amount) -> int:
	for slot: InventorySlot in $GridContainer.get_children():
		var held = slot.held_item
		if held != null and held.item_name == item.item_name:
			var subtracted = max(held.quantity, amount)
			held.quantity -= min(held.quantity, amount)
			amount -= subtracted
			slot.update_quantity()
			if amount <= 0:
				return 0
	
	return amount


# Return how much of amount is left
func has_item(item: InventoryItem, amount: int) -> int:
	for slot: InventorySlot in $GridContainer.get_children():
		var held = slot.held_item
		if held != null and held.item_name == item.item_name:
			amount -= held.quantity
			if amount <= 0:
				return 0
	
	return amount


func get_items() -> Array:
	var items = []
	for slot: InventorySlot in $GridContainer.get_children():
		var held = slot.held_item
		if held != null:
			items.append(held)
	
	return items


func generate_save() -> Dictionary:
	var save_dict = {
		"items": []
	}
	
	for item: InventoryItem in get_items():
		var stripped = item.item_name.replace(" ", "")
		save_dict["items"].append({
			"packed_path": "res://assets/nodes/inventoryItems/" + stripped + "Item.tres",
			"quantity": item.quantity
		})
	
	return save_dict

func parse_save(save_dict):
	for item in save_dict["items"]:
		var new_item = load(item["packed_path"]).duplicate()
		new_item.quantity = item["quantity"]
		add_item(new_item)

func save_bin(save_game: FileAccess):
	var save_dict = generate_save()
	save_game.store_var(save_dict)
