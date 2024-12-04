extends Grid

class_name ObjectGrid

const B = preload("res://assets/scripts/Bitmask.gd")

const PlacementParticles = preload("res://assets/effects/PlacementParticles.tscn")

var level_loaded = false
@export var initLevel: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.selected_object_grid.connect(_handle_input)
	SignalManager.rotate_object.connect(on_rotate_object)
	SignalManager.refresh_object.connect(on_refresh_object)
	initialize_level()


func _process(delta):
	set_hover_tile()
	_handle_input()
	update_hologram()


func _handle_input():
	if Input.is_action_just_pressed("right_click"):
		if grid.has(hover_tile):
			var cell = grid[hover_tile]
			for obj in cell.keys():
				print("Object", obj, " : ", hover_tile, " - ", B.bitmask2string(cell[obj]))
		else:
			print("Objects : ", hover_tile)


func initialize_level():
	if initLevel != null:
		if !level_loaded:
			for object in initLevel.get_children():
				add_object_to_grid(object, world_position_to_coord(object.position))
		
		initLevel.queue_free()


func on_rotate_object():
	var object = get_at(hover_tile)
	if object != null && object.has_method("rotate_clockwise"):
		object.rotate_clockwise()


func empty_cell(coord: Vector2i, object: Node2D = null):
	if grid.has(coord):
		if object == null:
			grid.erase(coord)
		else:
			grid[coord].erase(object)
			if len(grid[coord].keys()) == 0:
				grid.erase(coord)


func can_pick_up(coord: Vector2i = hover_tile) -> bool:
	var object = get_at(coord)
	if object != null && object.get_node("Grabbable") != null:
		return true
	
	return false


func pick_up(coord: Vector2i = hover_tile) -> Node2D:
	var object = get_at(coord)
	if object == null:
		return null
	
	object.get_node("Grabbable").grab()
	return object


func set_hologram(hologram: Node2D):
	$Hologram.set_hologram(hologram)


func activate_hologram():
	$Hologram.turn_on()


func deactivate_hologram():
	$Hologram.turn_off()


func update_hologram():
	$Hologram.target_position = cell_to_world_position(hover_tile)


func get_at(coord: Vector2i):
	if grid.has(coord):
		for object in grid[coord].keys():
			if grid[coord][object] & B.OCC != 0:
				return object
	else:
		return null


func remove_object(object: Node2D):
	empty_object_cells(object)
	objects.erase(object)
	object.queue_free()


func empty_object_cells(object: Node2D):
	var layout = object.layout
	var layout_height = len(layout)
	var layout_width = len(layout[0])
	
	var offset_y = layout_height / 2
	var offset_x = layout_width / 2
	var offset = Vector2i(offset_x, offset_y)
	
	for x in layout_width:
		for y in layout_height:
			var tile = objects[object] + Vector2i(x, y) - offset
			empty_cell(tile, object)


func fill_object_cells(object: Node2D, coord: Vector2i):
	var layout = object.layout
	var layout_height = len(layout)
	var layout_width = len(layout[0])
	
	var offset_y = layout_height / 2
	var offset_x = layout_width / 2
	var offset = Vector2i(offset_x, offset_y)
	
	# Validate if can be placed
	for x in layout_width:
		for y in layout_height:
			var cell = coord + Vector2i(x, y) - offset
			var layout_cell_type = layout[y][x]
			if validate_layout_cell(layout_cell_type, cell) == false:
				print("Object space occupied!")
				return false
	
	# Place object
	for x in layout_width:
		for y in layout_height:
			var object_cell = layout[y][x]
			var cell_coord = coord + Vector2i(x, y) - offset
			if object_cell > 0:
				add_object_to_grid_cell(object, object_cell, cell_coord)
	
	return true


func add_object_to_grid_cell(object: Node2D, cell_type: int, cell_coord: Vector2i):
	if !grid.has(cell_coord):
		grid[cell_coord] = {}
	
	grid[cell_coord][object] = cell_type


func validate_layout_cell(layout_cell_type: int, cell: Vector2i):
	if !grid.has(cell):
		return true
	
	for object in grid[cell].keys():
		var object_cell_type = grid[cell][object]
		if object_cell_type & layout_cell_type & B.ALL_COLL != 0:
			if object_cell_type & layout_cell_type & B.OCC != 0 or\
				(object_cell_type | layout_cell_type) & B.BLC != 0:
				return false
	
	return true


func on_refresh_object(object):
	var tile = objects[object]
	empty_object_cells(object)
	add_object_to_grid(object, tile)


func add_object_to_grid(new_object: Node2D, coord = hover_tile) -> bool:
	if !fill_object_cells(new_object, coord):
		return false
	
	# Set parent
	if new_object.get_parent() != null:
		new_object.get_parent().remove_child(new_object)
	add_child(new_object)
	
	# Add object to objects array for reverse look-up of placed coord
	objects[new_object] = coord
	new_object.position = cell_to_world_position(coord)
	
	if new_object.has_node("Placeable"):
		new_object.get_node("Placeable").release()
	
	return true

func create_placement_effect(coord = hover_tile):
	var placement_particles = PlacementParticles.instantiate()
	placement_particles.position = cell_to_world_position(coord)
	placement_particles.emitting = true
	add_child(placement_particles)
	SignalManager.set_screen_shake.emit(0.7,0.12)
	$AudioStreamPlayer.pitch_scale = randf_range(0.8, 1.2)
	$AudioStreamPlayer.play()


func interact_with_object_on_grid(interact_item: InventoryItem, coord = hover_tile) -> bool:
	var interact_object: Node2D = get_at(coord)
	
	if interact_object != null && interact_object.has_method("interact_with_item"):
		return interact_object.interact_with_item(interact_item)
	
	return false


func get_connected(object: Node2D) -> Array[Node2D]:
	var layout = object.layout
	var layout_height = len(layout)
	var layout_width = len(layout[0])
	
	var offset_y = layout_height / 2
	var offset_x = layout_width / 2
	var offset = Vector2i(offset_x, offset_y)
	
	var coord = objects[object]
	
	var connected: Array[Node2D] = []
	
	for x in layout_width:
		for y in layout_height:
			if layout[y][x] & B.ALL_COLL != 0:
				var connected_coord = coord + Vector2i(x, y) - offset
				for connected_object in grid[connected_coord].keys():
					if object != connected_object && connected_object not in connected:
						if is_connected_at(connected_coord, object, connected_object):
							connected.append(connected_object)
	
	return connected


func is_connected_at(coord: Vector2i, object_A: Node2D, object_B: Node2D) -> bool:
	var tile = grid[coord]
	var object_cell_A = tile[object_A]
	var object_cell_B = tile[object_B]
	
	var intersection = object_cell_A & object_cell_B
	var union = object_cell_A | object_cell_B
	
	if intersection & B.MID != 0:
		if intersection & B.DIAG_COLL and intersection & (B.ROT | B.TUB) != 0:
			return true
	elif union & B.MID != 0:
		if intersection & B.ADJ_COLL and intersection & (B.ROT | B.TUB) != 0:
			return true
	elif intersection & B.ALL_COLL and intersection & (B.ROT | B.TUB) != 0:
		return true
	
	return false


func generate_save() -> Dictionary:
	var save_dict = {
		"objects": [],
	}
	
	for object in objects.keys():
		if !object.has_method("generate_save"):
			print("WARNING: Cannot save ", object.item_name)
			continue
		
		var coord: Vector2 = objects[object]
		var object_save_dict = object.generate_save()
		object_save_dict["coord"] = coord
		save_dict["objects"].append(object_save_dict)
	
	return save_dict


func parse_save(save_dict):
	for object in save_dict["objects"]:
		var packed = load(object["packed_path"])
		var instance = packed.instantiate()
		if instance.has_method("parse_save"):
			instance.parse_save(object)
		add_object_to_grid(instance, Vector2i(object["coord"]))


func save_bin(save_game: FileAccess):
	var save_dict = generate_save()
	save_game.store_var(save_dict)


func load_bin(save_dict):
	parse_save(save_dict)
	level_loaded = true
	
