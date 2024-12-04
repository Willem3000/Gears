class_name Drop extends RigidBody2D

const DropTemplate: PackedScene = preload("res://assets/nodes/drops/DropTemplate.tscn")
const SPRITE_SIZE = 6
const item_index =  {
	"Stone Chunk": 1,
	"Iron Chunk": 2,
	"Coal Chunk": 3,
	"Copper Chunk": 4,
	"Gold Chunk": 5,
	"Ember": 6,
	"Small Cog": 7,
	"Large Cog": 8,
}

@export var inventory_item: InventoryItem = null:
	set(value):
		if value != null && has_node("Sprite2D"):
			inventory_item = value
			if item_index.has(inventory_item.item_name):
				var rect_x = item_index[inventory_item.item_name] * SPRITE_SIZE
				$Sprite2D.region_rect = Rect2(rect_x, 0, SPRITE_SIZE, SPRITE_SIZE)

@onready var behavior_grid: BehaviorGrid = get_tree().root.get_node("Overworld/BehaviorGrid")
@onready var object_grid: ObjectGrid = get_tree().root.get_node("Overworld/ObjectGrid")
@onready var ground_tiles: TileMap = get_tree().root.get_node("Overworld/GroundTiles")

var target = Vector2.ZERO
var time = 0.1

var in_tube = false:
	set(value):
		if value != in_tube:
			in_tube = value
			
			if in_tube == true:
				$SuctionSound.pitch_scale = 1.0 + randf_range(-0.5, 0.5)
				$SuctionSound.play()

var cell = null


func _ready():
	cell = object_grid.world_position_to_coord(global_position)
	var ground_tile = ground_tiles.get_cell_atlas_coords(0, cell, false)
	apply_ground_tile(ground_tile)


func _process(delta):
	time += delta
	if time > 0.1:
		var cell_pos = object_grid.world_position_to_coord(global_position)
		var ground_tile = ground_tiles.get_cell_atlas_coords(0, cell_pos, false)
		apply_ground_tile(ground_tile)
		var object = object_grid.get_at(cell_pos)
		apply_objects(object)
		var behaviors = behavior_grid.get_at(cell_pos)
		apply_behaviors(behaviors)
		time = 0


static func create(item: InventoryItem):
	var instance: Drop = DropTemplate.instantiate()
	instance.inventory_item = item
	return instance


func apply_ground_tile(tile):
	if collision_mask & (1 << 3) == 0 && (tile == Vector2i(3, 0) || tile == Vector2i(-1, -1)):
		collision_mask |= 1 << 3
		$Sprite2D.z_index = 0
		position += Vector2.DOWN * 6
		


func apply_objects(object: Node2D):
	if object != null && object.has_method("interact_with_item"):
		object.interact_with_item(inventory_item)
		queue_free()


func apply_behaviors(behaviors):
	if behaviors != null:
		for behavior_name in behaviors.keys():
			match behavior_name:
				"Wind":
					var wind: WindTile = behaviors[behavior_name]
					apply_force(wind.direction * wind.speed * 20000)
				"Suction":
					var suction: SuctionTile = behaviors[behavior_name]
					apply_force(suction.direction * suction.speed * 20000)
					in_tube = true
					return
				"Vortex":
					var vortex: VortexTile = behaviors[behavior_name]
					apply_force((vortex.center - position).normalized() * vortex.speed * 10000)
	
	in_tube = false
