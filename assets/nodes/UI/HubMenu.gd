extends Control

class_name HubMenu

var EmberItem = preload("res://assets/nodes/inventoryItems/EmberItem.tres")

var is_open = false

func _ready():
	_on_inventory_updated()
	for slot: InventorySlot in $GridContainer.get_children():
		slot.updated_slot.connect(_on_inventory_updated)
	close()
	$AnimationPlayer.stop()


func _on_inventory_updated():
	var ember_count = count_item(EmberItem)
	var ember_counter: Label = find_child("EmberCounter")
	ember_counter.text = str(ember_count) + "/1000"
	if ember_count >= 1000:
		set_nova_text("You did it SEP7! You collected 1000 embers and finished the demo. The Ember Corporation will be very pleased. Thank you for playing!")


func toggle():
	if is_open:
		close()
	else:
		open()


func open():
	is_open = true
	$AudioStreamPlayer2D.stream = load("res://assets/sound/sound_effects/HologramOpen.wav")
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.stop()	
	$AnimationPlayer.speed_scale = 3
	$AnimationPlayer.play("OpenHubMenu")
	pass


func close():
	is_open = false
	$AudioStreamPlayer2D.stream = load("res://assets/sound/sound_effects/HologramClose.wav")
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.speed_scale = 4	
	$AnimationPlayer.play_backwards("OpenHubMenu")
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


func get_items_of_type(item: InventoryItem) -> Array:
	var items = []
	for slot: InventorySlot in $GridContainer.get_children():
		var held = slot.held_item
		if held != null && item.item_name == held.item_name:
			items.append(held)
	
	return items


func count_item(counted_item: InventoryItem) -> int:
	var count: int = 0
	
	var items = get_items_of_type(counted_item)
	for item: InventoryItem in items:
		count += item.quantity
	
	return count


func clear_items():
	for slot: InventorySlot in $GridContainer.get_children():
		var held = slot.held_item
		if held != null:
			slot.held_item = null


func _on_nova_interactor_pressed():
	talk_to_nova()


func talk_to_nova():
	set_nova_text("To start, put the engine, coal and mining drill from Ember Corp. in your inventory [E]. Try to place them in the world!")


func set_nova_text(text):
	var nova_text: RichTextLabel = find_child("NovaText")
	nova_text.text = text


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
	clear_items()
	for item in save_dict["items"]:
		var new_item = load(item["packed_path"]).duplicate()
		new_item.quantity = item["quantity"]
		add_item(new_item)
