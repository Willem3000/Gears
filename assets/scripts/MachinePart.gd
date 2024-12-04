extends Node2D

class_name MachinePart

# Graphnode system which is used to connect machineparts together

signal attached
signal detached
signal highlight_color_changed(color)

var neighbours: Array = []

var highlight_color: Vector3 = Vector3(0.0, 0.0, 0.0):
	set(value):
		highlight_color = value
		highlight_color_changed.emit(highlight_color)

func activate_machine():
	var engine = find_engine()
	if engine != null:
		print("\nValidating machine...")
		engine.validate_machine()


func restart_machine():
	reset_machine()
	activate_machine()


func _process(delta: float) -> void:
	if highlight_color.x > 0.0:
		highlight_color = lerp(highlight_color, Vector3(0.0, 0.0, 0.0), 0.2)


# BFS function which validates all connected nodes in machine
func validate_machine(visited=[], queue=[self]) -> bool:
	var valid_neighbours = []
	
	for n in neighbours:
		if n not in visited:
			var OK = validate_parts(n)
			if OK:
				valid_neighbours.append(n)

	visited.append(queue[0])
	if len(queue[0].neighbours) > 0:
		for n in queue[0].neighbours:
			if not (n in visited or n in queue) and n in valid_neighbours:
				queue.append(n)
	queue.remove_at(0)
	
	if len(queue) > 0:
		if queue[0].validate_machine(visited, queue) == false:
			return false
	
	return true


func validate_parts(other: Node2D) -> bool:
	print(self.get_parent().item_name, " INTERACTING WITH ", other.get_parent().item_name)
	return get_parent().interact_with(other)


# Resets all nodes in machine
func reset_machine(visited=[], queue=[self]):
	get_parent().reset()
	
	visited.append(queue[0])
	if len(queue[0].neighbours) > 0:
		for n in queue[0].neighbours:
			if not (n in visited or n in queue):
				queue.append(n)
	queue.remove_at(0)
	
	if len(queue) > 0:
		queue[0].reset_machine(visited, queue)


func find_engine(visited=[], queue=[self]) -> Node2D:
	if "Engine" in get_parent().item_name:
		return self
	
	visited.append(queue[0])
	if len(queue[0].neighbours) > 0:
		for n in queue[0].neighbours:
			if not (n in visited or n in queue):
				queue.append(n)
	queue.remove_at(0)
	
	if len(queue) > 0:
		var engine = queue[0].find_engine(visited, queue)
		if engine != null:
			return engine
	
	return null


func attach(machine_part: MachinePart):
	highlight_color = Vector3(0.4, 0.4, 0.4)
	neighbours.append(machine_part)
	machine_part.attach_neighbour(self)
	attached.emit()


func attach_neighbour(neighbour: MachinePart):
	highlight_color = Vector3(0.4, 0.4, 0.4)
	neighbours.append(neighbour)
	attached.emit()


func detach():
	reset_machine()
	for n in neighbours:
		n.detach_neighbour(self)
	for n in neighbours:
		n.activate_machine()
	neighbours.clear()
	detached.emit()


func detach_neighbour(neighbour: MachinePart):
	neighbours.erase(neighbour)
	detached.emit()
