class_name BehaviorGrid extends Grid

const B = preload("res://assets/scripts/Bitmask.gd")

func _process(delta):
	set_hover_tile()
	_handle_input()


func _handle_input():
	if Input.is_action_just_pressed("right_click"):
		if grid.has(hover_tile):
			var cell = grid[hover_tile]
			print("Behavior: ", hover_tile, " - ", cell)
		else:
			print("Behavior: ", hover_tile)


func add_behaviour_to_grid(behavior: ITileBehavior):
	var cell = behavior.tile_position
	
	if !grid.has(cell):
		grid[cell] = {}
	
	if !grid[cell].has(behavior.tile_name):
		grid[cell][behavior.tile_name] = behavior
		behavior.position = cell_to_world_position(behavior.tile_position)
		if behavior.has_method("update_particles"):
			behavior.update_particles()
		add_child(behavior)
	else:
		grid[cell][behavior.tile_name].combine(behavior)


func remove_behavior_from_grid(behavior: ITileBehavior):
	var cell = behavior.tile_position
	if grid.has(cell) && grid[cell].has(behavior.tile_name):
		grid[cell][behavior.tile_name].seperate(behavior)
		if !grid[cell][behavior.tile_name].is_active():
			grid[cell][behavior.tile_name].queue_free()
			grid[cell].erase(behavior.tile_name)
			if grid[cell].is_empty():
				grid.erase(cell)


func get_at(coord: Vector2i):
	if grid.has(coord):
		return grid[coord]
	else:
		return null
