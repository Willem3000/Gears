extends Node2D

var layout = [	[B.ROT|B.MID|B.DR, 			B.NA, B.NA],
				[B.ROT|B.MID|B.DR|B.TR|B.R, B.OCC|B.ALL_COLL, B.TUB|B.L],
				[B.ROT|B.MID|B.TR, 			B.NA, B.NA]]

@onready var item = load("res://assets/nodes/inventoryItems/VacuumItem.tres")

var item_name:
	get:
		return item.item_name

func _ready():
	$Breakable.dropped_items.append(item)
	$Breakable.broken.connect(detach)
	$Placeable.connect("object_placed", _on_object_placed)
	$Rotary.rotation_speed = 0
	$MachinePart.highlight_color_changed.connect(set_highlight_color)


func _process(delta):
	use_vacuum()


func use_vacuum():
	var drops = get_tree().root.get_node("Overworld/Drops")
	var vacuum_pos: Vector2 = $VacuumPosition.global_position
	for drop in drops.get_children():
		if drop is Drop:
			var distance = vacuum_pos.distance_to(drop.position)
			if distance > 5 && distance < 60:
				if !drop.in_tube:
					drop.apply_force((vacuum_pos - drop.position) * (500/(max(4,distance-8))))


func set_highlight_color(color):
	$Sprite2D.material.set_shader_parameter("highlight_color",color)


func damage(dmg):
	var breakable = $Breakable
	breakable.damage(dmg)


func detach():
	$Rotary.rotation_speed = 0
	$MachinePart.detach()


func _on_object_placed():
	$Rotary.rotation_speed = 0
	
	var object_grid = get_tree().root.get_node("Overworld/ObjectGrid")
	var connected_objects = object_grid.get_connected(self)
	
	for object in connected_objects:
		$MachinePart.attach(object.find_child("MachinePart"))
	
	$MachinePart.restart_machine()


func reset():
	pass


func interact_with_item(other: InventoryItem):
	return false
