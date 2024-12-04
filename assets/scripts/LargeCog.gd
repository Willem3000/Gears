extends Node2D

var layout = 	[[B.ROT|B.DR, B.OCC|B.D, B.ROT|B.DL],
				[B.OCC|B.R,B.OCC|B.BLC|B.ALL_COLL, B.OCC|B.L],
				[B.ROT|B.TR, B.OCC|B.T, B.ROT|B.TL]]

@onready var item = load("res://assets/nodes/inventoryItems/LargeCogItem.tres")

var item_name:
	get:
		return item.item_name


func _ready():
	$Breakable.dropped_items.append(item)
	$Breakable.broken.connect(detach)
	$Placeable.connect("object_placed", _on_object_placed)
	$MachinePart.highlight_color_changed.connect(set_highlight_color)


func set_highlight_color(color):
	$SpriteStack.set_highlight_color(color)


func damage(dmg):
	var breakable = $Breakable
	breakable.damage(dmg)


func _on_object_placed():
	var object_grid = get_tree().root.get_node("Overworld/ObjectGrid")
	var connected_objects = object_grid.get_connected(self)
	
	for object in connected_objects:
		$MachinePart.attach(object.find_child("MachinePart"))
		pass
	
	$MachinePart.restart_machine()


func detach():
	$Rotary.rotation_speed = 0
	$MachinePart.detach()


func reset():
	$Rotary.rotation_speed = 0


func interact_with(other: Node2D):
	var other_name = other.get_parent().item_name
	
	match other_name:
		"Small Cog", "Drill":
			var small_cog = other.get_parent()
			var small_cog_rotary = small_cog.find_child("Rotary")
			
			if small_cog_rotary.rotation_speed == 0:
				small_cog_rotary.rotation_speed = -$Rotary.rotation_speed * 2
			elif $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -small_cog_rotary.rotation_speed / 2
			elif small_cog_rotary.rotation_speed != $Rotary.rotation_speed / 2 * -1:
				return false

		"Engine":
			var engine = other.get_parent()
			var engine_rotary = engine.find_child("Rotary")
			
			if $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -engine_rotary.rotation_speed / 2
			elif engine_rotary.rotation_speed != $Rotary.rotation_speed / 2 * -1:
				return false

	return true


func generate_save() -> Dictionary:
	var save_dict = {
		"packed_path": scene_file_path,
	}
	
	return save_dict
