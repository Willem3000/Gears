class_name Breakable extends Node2D

signal broken

@export var break_effect_pack: PackedScene
@export var total_health: float = 1
@export var dropped_items: Array[InventoryItem]
@export var indestructable : bool = false
@export var health: float = 1

@onready var drops = get_tree().root.get_node("Overworld/Drops")

func damage(dmg):
	if !indestructable && health > 0:
		health -= dmg
		
		if health <= 0:
			break_block()
			broken.emit()

func break_block():
	broken.emit()
	
	# Create effect
	var break_effect = break_effect_pack.instantiate()
	break_effect.position = global_position
	get_tree().root.get_node("Overworld").add_child(break_effect)
	SignalManager.set_local_screen_shake.emit(1, 0.2, global_position)
	
	# Spawn drops
	for dropped_item: InventoryItem in dropped_items:
		for i in dropped_item.quantity:
			var single_drop = dropped_item.duplicate()
			single_drop.quantity = 1
			var resource = Drop.create(single_drop)
			var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			var speed = 50
			
			resource.position = global_position
			resource.apply_impulse(direction * speed)
			drops.add_child(resource)
	
	# Destroy
	var object_grid: ObjectGrid = get_tree().root.get_node("Overworld/ObjectGrid")
	if object_grid != null:
		object_grid.remove_object(get_parent())
