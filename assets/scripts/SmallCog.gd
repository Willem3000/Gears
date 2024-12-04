extends Node2D

const layout = [[B.NA, B.ROT|B.D, B.NA],
				[B.ROT|B.R, B.ROT|B.OCC|B.ALL_COLL, B.ROT|B.L],
				[B.NA, B.ROT|B.T, B.NA]]

@onready var item = load("res://assets/nodes/inventoryItems/SmallCogItem.tres")

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


func detach():
	$Rotary.rotation_speed = 0
	$MachinePart.detach()


func _on_object_placed():
	var object_grid = get_tree().root.get_node("Overworld/ObjectGrid")
	var connected_objects = object_grid.get_connected(self)
	
	for object in connected_objects:
		$MachinePart.attach(object.find_child("MachinePart"))
		pass
	
	$MachinePart.restart_machine()


func reset():
	$Rotary.rotation_speed = 0


func interact_with(other: Node2D):
	var other_name = other.get_parent().item_name

	match other_name:
		"Small Cog", "Drill", "Wall Drill", "Fan", "Tube Fan", "Laser Drill":
			var small_cog = other.get_parent()
			var small_cog_rotary = small_cog.find_child("Rotary")
			
			if small_cog_rotary.rotation_speed == 0:
				small_cog_rotary.rotation_speed = -$Rotary.rotation_speed
			elif $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -small_cog_rotary.rotation_speed
			elif small_cog_rotary.rotation_speed != $Rotary.rotation_speed * -1:
				return false

		"Large Cog":
			var large_cog = other.get_parent()
			var large_cog_rotary = large_cog.find_child("Rotary")
			
			if large_cog_rotary.rotation_speed == 0:
				large_cog_rotary.rotation_speed = -$Rotary.rotation_speed / 2
			elif $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -large_cog_rotary.rotation_speed * 2
			elif large_cog_rotary.rotation_speed != $Rotary.rotation_speed / 2 * -1:
				return false

		"Engine":
			var engine = other.get_parent()
			var engine_rotary = engine.find_child("Rotary")
			
			if $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -engine_rotary.rotation_speed
			elif engine_rotary.rotation_speed != $Rotary.rotation_speed * -1:
				return false

	return true


func generate_save() -> Dictionary:
	var save_dict = {
		"packed_path": scene_file_path,
	}
	
	return save_dict
