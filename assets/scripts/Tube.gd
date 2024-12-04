class_name Tube extends Node2D

var layout = [[B.NA, B.TUB|B.D, B.NA],
				[B.TUB|B.R, B.OCC|B.TUB|B.ALL_COLL, B.TUB|B.L],
				[B.NA, B.TUB|B.T, B.NA]]

@onready var item = load("res://assets/nodes/inventoryItems/TubeItem.tres")

const SPRITE_SIZE = 20

var item_name:
	get:
		return item.item_name

@onready var static_body: StaticBody2D = $StaticBody2DStraight:
	set(value):
		if value != static_body && value is StaticBody2D:
			static_body.collision_layer = 0
			static_body.visible = false
			static_body = value
			static_body.collision_layer = 2
			static_body.visible = true

enum {
	STRAIGHT,
	CORNER,
	T_JUNCTION,
	INTERSECTION
}

enum {
	IDLE,
	PUSHING,
	PULLING
}

var suction_tiles = []
var tube_type = STRAIGHT
var suction_type = IDLE


func _ready():
	$Breakable.dropped_items.append(item)
	$Breakable.broken.connect(detach)
	$Placeable.object_placed.connect(_on_object_placed)
	$Suction.changed_speed.connect(_on_suction_speed_changed)
	$Suction.changed_direction.connect(_on_suction_direction_changed)
	$MachinePart.detached.connect(_on_neighbours_reconfigured)
	$MachinePart.attached.connect(_on_neighbours_reconfigured)
	$MachinePart.highlight_color_changed.connect(set_highlight_color)

func damage(dmg):
	var breakable = $Breakable
	breakable.damage(dmg)


func detach():
	$Suction.reset()
	$MachinePart.detach()


func set_highlight_color(color):
	$Sprite2D.material.set_shader_parameter("highlight_color",color)


func _on_object_placed():
	var object_grid = get_tree().root.get_node("Overworld/ObjectGrid")
	var connected_objects = object_grid.get_connected(self)
	
	for object in connected_objects:
		$MachinePart.attach(object.find_child("MachinePart"))
	
	$MachinePart.restart_machine()


func _on_suction_speed_changed():
	apply_behavior()


func _on_neighbours_reconfigured():
	set_tube_sprite()


func get_tube_rect(index) -> Rect2:
	return Rect2(SPRITE_SIZE * index, 0, SPRITE_SIZE, SPRITE_SIZE)


func set_tube_sprite():
	var nbrs = $MachinePart.neighbours
	
	match(len(nbrs)):
		0:
			tube_type = STRAIGHT
			$Sprite2D.region_rect = get_tube_rect(2)
			
			static_body = $StaticBody2DStraight
		1:
			tube_type = STRAIGHT
			var dir = (nbrs[0].get_parent().position - position).normalized().round()
			$Sprite2D.region_rect = get_tube_rect(1)
			$Sprite2D.rotation = dir.angle()
			
			static_body = $StaticBody2DStraight
			static_body.rotation = dir.angle()
		2:
			var corner_dir = (nbrs[0].get_parent().position - nbrs[1].get_parent().position).normalized().round()
			var angle = round(rad_to_deg(corner_dir.angle()))
			var is_corner = int(angle)%90 != 0
			if is_corner:
				tube_type = CORNER
				$Sprite2D.region_rect = get_tube_rect(11)
				var dir = (nbrs[0].get_parent().position - position).normalized().round()\
							+ (nbrs[1].get_parent().position - position).normalized().round()
				$Sprite2D.rotation = dir.angle() - deg_to_rad(45)
		
				static_body = $StaticBody2DCorner
				static_body.rotation = dir.angle() - deg_to_rad(45)
			else:
				tube_type = STRAIGHT
				$Sprite2D.region_rect = get_tube_rect(0)
				var dir = (nbrs[0].get_parent().position - position).normalized().round()
				$Sprite2D.rotation = dir.angle()
				
				static_body = $StaticBody2DStraight
				static_body.rotation = dir.angle()
		3:
			tube_type = T_JUNCTION
			$Sprite2D.region_rect = get_tube_rect(5)
			var direction = Vector2.ZERO
			for i in 3:
				var dir = (nbrs[i].get_parent().position - position).normalized().round()\
							+ (nbrs[(i+1)%3].get_parent().position - position).normalized().round()
				if dir.x == 0 || dir.y == 0:
					direction = nbrs[(i+2)%3].get_parent().position - position
			$Sprite2D.rotation = direction.angle()
			
			static_body = $StaticBody2DTJunction
			static_body.rotation = direction.angle()
		4:
			tube_type = INTERSECTION
			$Sprite2D.region_rect = get_tube_rect(8)
			
			static_body = $StaticBody2DIntersection


func _on_suction_direction_changed():
	#TODO: This solution cycles twice, needs less overhead
	if tube_type == CORNER:
		var new_direction = Vector2i.ZERO
		var nbrs = $MachinePart.neighbours
		for i in len(nbrs):
			var n = nbrs[i]
			var tube = n.get_parent()
			var tube_suction = tube.find_child("Suction")
			if tube_suction != null && tube_suction.suction_speed != 0:
				if tube_suction.suction_direction == Vector2i((position - tube.position).normalized()): # PUSH
					new_direction = Vector2i((nbrs[(i+1)%2].get_parent().position - position).normalized())
				else: #SUCK
					new_direction = Vector2i((tube.position - position).normalized())
		
		if $Suction.suction_direction != new_direction && new_direction != Vector2i.ZERO:
			$Suction.suction_direction = new_direction
	
	apply_behavior()


func rotate_clockwise():
	#TODO: Turn the garbage below in a proper matrix rotation
	var rotated_layout = [	[B.NA, B.NA, B.NA],
							[B.NA, B.NA, B.NA],
							[B.NA, B.NA, B.NA]]
	
	rotated_layout[0][1] = B.rotate_mask(layout[1][0], 2)
	rotated_layout[1][2] = B.rotate_mask(layout[0][1], 2)
	rotated_layout[2][1] = B.rotate_mask(layout[1][2], 2)
	rotated_layout[1][0] = B.rotate_mask(layout[2][1], 2)
	
	rotated_layout[1][1] = B.rotate_mask(layout[1][1], 2)
	
	layout = rotated_layout
	
	$Sprite2D.rotate(PI/2)


func apply_behavior():
	reset_behavior()
	if $Suction.suction_speed > 0:
		var behavior_grid: BehaviorGrid = get_tree().root.get_node("Overworld/BehaviorGrid")
		var object_grid: ObjectGrid = get_tree().root.get_node("Overworld/ObjectGrid")
		var cell_pos = object_grid.objects[self]
		var suction_position = cell_pos
		var tile = SuctionTile.new_tile(suction_position, $Suction.suction_direction, 2)
		suction_tiles.append(tile)
		behavior_grid.add_behaviour_to_grid(tile)
		if len($MachinePart.neighbours) == 1:
			if $Suction.suction_direction == suction_position - object_grid.objects[$MachinePart.neighbours[0].get_parent()]:
				tile = WindTile.new_tile(suction_position + $Suction.suction_direction, $Suction.suction_direction, 2)
			else:
				tile = VortexTile.new_tile(suction_position - $Suction.suction_direction, position, 2)
				suction_type = PULLING
			
			suction_tiles.append(tile)
			behavior_grid.add_behaviour_to_grid(tile)


func reset_behavior():
	var behavior_grid: BehaviorGrid = get_tree().root.get_node("Overworld/BehaviorGrid")
	for tile in suction_tiles:
		behavior_grid.remove_behavior_from_grid(tile)
	suction_tiles.clear()


func reset():
	$Suction.reset()
	suction_type = IDLE


func interact_with(other: Node2D):
	var other_name = other.get_parent().item_name

	match other_name:
		"Tube":
			var tube = other.get_parent()
			var tube_suction = tube.find_child("Suction")
			if tube_suction.suction_speed == 0:
				match tube_type:
					CORNER:
						if Vector2i((tube.position - position).normalized()) == $Suction.suction_direction:
							tube_suction.suction_direction = Vector2i((tube.position - position).normalized())
						else:
							tube_suction.suction_direction = Vector2i((position - tube.position).normalized())
					STRAIGHT, INTERSECTION:
						if Vector2i((tube.position - position).normalized()) == $Suction.suction_direction:
							tube_suction.suction_direction = Vector2i((tube.position - position).normalized())
						else:
							tube_suction.suction_direction = Vector2i((position - tube.position).normalized())
					T_JUNCTION:
						if Vector2i((tube.position - position).normalized()) == $Suction.suction_direction:
							tube_suction.suction_direction = Vector2i((tube.position - position).normalized())
						else:
							tube_suction.suction_direction = Vector2i((position - tube.position).normalized())
				tube_suction.suction_speed = $Suction.suction_speed
				
				return true
		
		"Tube Fan":
			var tube = other.get_parent()
			var tube_suction = tube.find_child("Suction")
			
			if $Suction.suction_speed == 0:
				$Suction.suction_direction = (position - tube.position).normalized()
				$Suction.suction_speed = tube_suction.suction_speed
				
				return true

	return false

func generate_save() -> Dictionary:
	var save_dict = {
		"packed_path": scene_file_path,
	}
	
	return save_dict
