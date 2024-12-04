extends Control

@export var ObjectGridInstance: ObjectGrid

var held_item: InventoryItem = null :
	set(value):
		held_layout = null
		held_item = value
		
		var quantity_string = ""
		var cursor_texture = null
		
		if held_item != null && held_item.quantity > 0:
			cursor_texture = held_item.icon
			quantity_string = str(held_item.quantity)
			var object = held_item.to_object()
			if object != null:
				held_layout = object.layout
		
		update_hologram()
		$Label.text = quantity_string
		$HeldItemTexture.texture = cursor_texture

var held_layout = null

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.selected_inventory_slot.connect(on_selected_inventory_slot)
	SignalManager.selected_crafting_slot.connect(on_selected_crafting_slot)
	SignalManager.shift_selected_object_grid.connect(on_shift_selected_object_grid)
	SignalManager.selected_object_grid.connect(on_selected_object_grid)
	SignalManager.spawn_drop.connect(on_spawn_drop)
	SignalManager.rotate_object.connect(on_rotate_hologram)

func _process(delta):
	position = get_global_mouse_position()

func on_spawn_drop():
	var camera_position = get_tree().root.get_node("Overworld/Camera2D").position
	var coal_item = load("res://assets/nodes/inventoryItems/CoalChunkItem.tres")
	var drops = get_tree().root.get_node("Overworld/Drops")
	var resource: Drop = Drop.create(coal_item)
	resource.global_position = camera_position
	drops.add_child(resource)

func on_rotate_hologram():
	if held_item != null && held_item.packed != null:
		var object = held_item.to_object()
		if held_layout == null || !object.has_method("rotate_clockwise"):
			return
		
		object.layout = held_layout
		object.rotate_clockwise(false)
		held_layout = object.layout
		update_hologram()

func update_hologram():
	var hologram = null
	
	if held_item != null && held_item.packed != null:
		var object = held_item.to_object()
		
		while held_layout != object.layout:
			object.rotate_clockwise(false)
		
		if object.has_node("AnimatedSprite2D"):
			hologram = object.find_child("AnimatedSprite2D").duplicate()
		elif object.has_node("SpriteStack"):
			hologram = object.find_child("SpriteStack").duplicate()
		elif object.has_node("Sprite2D"):
			hologram = object.find_child("Sprite2D").duplicate()
		object.queue_free()
		
	ObjectGridInstance.set_hologram(hologram)

func on_selected_crafting_slot(slot):
	if slot.can_craft():
		if held_item == null:
			held_item = slot.craft()
		elif held_item.item_name == slot.recipe.item_name:
			var crafted = slot.craft()
			if crafted != null:
				held_item.quantity += 1
				update_quantity()
	
	return null

func on_selected_inventory_slot(slot):
	var swap_item = null
	if held_item != null:
		swap_item = held_item
	held_item = slot.swap_out(swap_item)
	
	if held_item != null:
		$HeldItemTexture.texture = held_item.icon
	else:
		$HeldItemTexture.texture = null
		reset_cursor()

func on_hover_object_grid():
	if held_item != null:
		var holo_object = held_item.to_object()
		ObjectGridInstance.display_hologram(holo_object)

func deduct_stack():
	if held_item != null:
		if held_item.quantity > 1:
			held_item.quantity -= 1
			update_quantity()
			return
	
	reset_cursor()

func on_selected_object_grid():
	if held_item != null:
		if held_item.packed != null:
			var placed_object = held_item.to_object()
			if held_layout != null && placed_object.has_method("rotate_clockwise"):
				while held_layout != placed_object.layout:
					placed_object.rotate_clockwise(false)
			var OK = ObjectGridInstance.add_object_to_grid(placed_object)
			if OK:
				ObjectGridInstance.create_placement_effect()
				deduct_stack()
		else:
			var OK = ObjectGridInstance.interact_with_object_on_grid(held_item)
			if OK:
				deduct_stack()
	elif ObjectGridInstance.can_pick_up():
		var object = ObjectGridInstance.pick_up()
		if object != null:
			held_layout = object.layout
			held_item = object.item


func on_shift_selected_object_grid():
	if ObjectGridInstance.can_pick_up():
		var object = ObjectGridInstance.pick_up()
		if object != null:
			var new_item = object.item
			SignalManager.add_to_inventory.emit(new_item)


func update_quantity():
	var quantity_string = ""
	if held_item != null:
		if held_item.quantity > 0:
			quantity_string = str(held_item.quantity)
	
	$Label.text = quantity_string

func reset_cursor():
	held_item = null
	held_layout = null

func generate_save() -> Dictionary:
	var save_dict = {}

	if held_item != null:
		var stripped = held_item.item_name.replace(" ", "")
		save_dict["item"] = {
			"packed_path": "res://assets/nodes/inventoryItems/" + stripped + "Item.tres",
			"quantity": held_item.quantity
		}
	
	return save_dict

func parse_save(save_dict):
	if save_dict.has("item"):
		var item = save_dict["item"]
		var new_item = load(item["packed_path"]).duplicate()
		new_item.quantity = item["quantity"]
		held_item = new_item

func save_bin(save_game: FileAccess):
	var save_dict = generate_save()
	save_game.store_var(save_dict)
