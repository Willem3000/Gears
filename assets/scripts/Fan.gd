extends Node2D

var layout = [	[B.ROT|B.MID|B.DR, 			B.NA, B.NA],
				[B.ROT|B.MID|B.DR|B.TR|B.R, B.ROT|B.OCC|B.L, B.NA],
				[B.ROT|B.MID|B.TR, 			B.NA, B.NA]]

@onready var item = load("res://assets/nodes/inventoryItems/FanItem.tres")

var item_name:
	get:
		return item.item_name

@onready var drops = get_tree().root.get_node("Overworld/Drops")

var wind_tiles = []
var fan_direction = Vector2(1,0)


func _ready():
	$Breakable.dropped_items.append(item)
	$Breakable.broken.connect(detach)
	$Placeable.connect("object_placed", _on_object_placed)
	$Rotary.connect("changed_rotation", _on_rotation_changed)
	$MachinePart.highlight_color_changed.connect(set_highlight_color)


func set_highlight_color(color):
	$AnimatedSprite2D.material.set_shader_parameter("highlight_color",color)


func damage(dmg):
	var breakable = $Breakable
	breakable.damage(dmg)


func _on_rotation_changed():
	apply_animation()
	apply_behavior()


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


func apply_animation():
	var rot_speed = $Rotary.rotation_speed
	
	if abs(rot_speed) > 0:
		if !$AnimatedSprite2D.is_playing():
			if rot_speed < 0:
				$AnimatedSprite2D.play("default")
			else:
				$AnimatedSprite2D.play_backwards("default")


func apply_behavior():
	reset_behavior()
	var rot_speed = $Rotary.rotation_speed
	if abs(rot_speed) > 0:
		var behavior_grid: BehaviorGrid = get_tree().root.get_node("Overworld/BehaviorGrid")
		var object_grid: ObjectGrid = get_tree().root.get_node("Overworld/ObjectGrid")
		var cell_pos = object_grid.objects[self]
		for x in range(0,5):
			var tile_position = cell_pos + Vector2i(fan_direction) * x
			var wind_tile = WindTile.new_tile(tile_position, Vector2i(fan_direction), 1)
			wind_tiles.append(wind_tile)
			behavior_grid.add_behaviour_to_grid(wind_tile)


func reset_behavior():
	var behavior_grid: BehaviorGrid = get_tree().root.get_node("Overworld/BehaviorGrid")
	for tile in wind_tiles:
		behavior_grid.remove_behavior_from_grid(tile)
	wind_tiles.clear()


func rotate_clockwise(refresh = true):
	#TODO: Turn the garbage below in a proper matrix rotation
	var rotated_layout = [	[B.NA, B.NA, B.NA],
							[B.NA, B.NA, B.NA],
							[B.NA, B.NA, B.NA]]
	
	rotated_layout[0][0] = B.rotate_mask(layout[2][0], 2) # DL to TL
	rotated_layout[0][1] = B.rotate_mask(layout[1][0], 2) # L TO T
	rotated_layout[0][2] = B.rotate_mask(layout[0][0], 2) # TL to TR
	rotated_layout[1][2] = B.rotate_mask(layout[0][1], 2) # T TO R
	rotated_layout[2][2] = B.rotate_mask(layout[0][2], 2) # TR TO DR
	rotated_layout[2][1] = B.rotate_mask(layout[1][2], 2) # R TO D
	rotated_layout[2][0] = B.rotate_mask(layout[2][2], 2) # DR TO DL
	rotated_layout[1][0] = B.rotate_mask(layout[2][1], 2) # D TO L
	
	rotated_layout[1][1] = B.rotate_mask(layout[1][1], 2) # CENTER
	
	layout = rotated_layout
	
	fan_direction = fan_direction.rotated(PI/2)
	fan_direction = Vector2(round(fan_direction.x), round(fan_direction.y))
	
	if refresh:
		detach()
		SignalManager.refresh_object.emit(self)
	
	$AnimatedSprite2D.rotate(PI/2)
	$StaticBody2D.rotate(PI/2)

func reset():
	$Rotary.rotation_speed = 0
	$AnimatedSprite2D.stop()
	reset_behavior()

func interact_with(other: Node2D):
	var other_name = other.get_parent().item_name

	match other_name:
		"Small Cog", "Drill", "Wall Drill", "Fan", "Tube Fan":
			var small_cog = other.get_parent()
			var small_cog_rotary = small_cog.find_child("Rotary")
			
			if small_cog_rotary.rotation_speed == 0:
				small_cog_rotary.rotation_speed = -$Rotary.rotation_speed
			elif $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -small_cog_rotary.rotation_speed
			elif small_cog_rotary.rotation_speed != $Rotary.rotation_speed * -1:
				return false
			
			return true

		"Large Cog":
			var large_cog = other.get_parent()
			var large_cog_rotary = large_cog.find_child("Rotary")
			
			if large_cog_rotary.rotation_speed == 0:
				large_cog_rotary.rotation_speed = -$Rotary.rotation_speed / 2
			elif $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -large_cog_rotary.rotation_speed * 2
			elif large_cog_rotary.rotation_speed != $Rotary.rotation_speed / 2 * -1:
				return false
			
			return true

		"Engine":
			var engine = other.get_parent()
			var engine_rotary = engine.find_child("Rotary")
			
			if $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -engine_rotary.rotation_speed
			elif engine_rotary.rotation_speed != $Rotary.rotation_speed * -1:
				return false
			
			return true

	return false


func parse_save(save_dict):
	if save_dict.has("rotation_mask"):
		var rotation_mask = save_dict["rotation_mask"]
		
		while layout[1][1] != rotation_mask:
			rotate_clockwise(false)


func generate_save() -> Dictionary:
	var save_dict = {
		"packed_path": scene_file_path,
		"rotation_mask": layout[1][1]
	}
	
	return save_dict
