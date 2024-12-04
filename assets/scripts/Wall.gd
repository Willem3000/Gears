@tool
class_name Wall extends Node2D

var item_name = "Wall"

signal exploded

const layout = [[B.NA, B.NA, B.NA],
				[B.NA, B.OCC|B.ALL_COLL, B.NA],
				[B.NA, B.NA, B.NA]]

@export var wall_resource: WallResource = null:
	set(value):
		item_name = wall_resource.item_name
		wall_resource = value
		if has_node("Breakable"):
			$Breakable.total_health = wall_resource.total_health
			$Breakable.health = wall_resource.total_health
			$Breakable.dropped_items = wall_resource.dropped_items
			$Breakable.indestructable = wall_resource.indestructable
			$Side.texture = wall_resource.sprite

func _ready():
	if wall_resource != null:
		$Breakable.total_health = wall_resource.total_health
		$Breakable.health = wall_resource.total_health
		$Breakable.dropped_items = wall_resource.dropped_items
		$Breakable.indestructable = wall_resource.indestructable
		$Side.texture = wall_resource.sprite


func damage(dmg):
	$Breakable.damage(dmg)


func generate_save() -> Dictionary:
	var save_dict = {
		"packed_path": scene_file_path,
		"wall_resource": wall_resource.resource_path,
	}
	
	return save_dict


func parse_save(save_dict: Dictionary):
	wall_resource = load(save_dict["wall_resource"])
