extends Node2D

var active = false
var drilling := false:
	set(value):
		if value != drilling:
			drilling = value
			$GPUParticles2D.emitting = drilling
	
var timer = 0.0
var laser_heat = 0.0

@export var target_position: Node2D = null

const StoneItem = preload("res://assets/nodes/inventoryItems/StoneChunkItem.tres")
const StoneParticle = preload("res://assets/sprites/StoneChunkParticle.png")
const IronItem = preload("res://assets/nodes/inventoryItems/IronChunkItem.tres")
const IronParticle = preload("res://assets/sprites/IronChunkParticle.png")
const CoalItem = preload("res://assets/nodes/inventoryItems/CoalChunkItem.tres")
const CoalParticle = preload("res://assets/sprites/CoalChunkParticle.png")
const CopperItem = preload("res://assets/nodes/inventoryItems/CopperChunkItem.tres")
const CopperParticle = preload("res://assets/sprites/CopperChunkParticle.png")
const EmberItem = preload("res://assets/nodes/inventoryItems/EmberItem.tres")
const EmberParticle = preload("res://assets/sprites/EmberParticle.png")

const ParticleChunkRamp: GradientTexture1D = preload("res://assets/effects/DrillParticleChunkRamp.tres")
const ParticleEmberRamp: GradientTexture1D = preload("res://assets/effects/DrillParticleEmberRamp.tres")

const STONE = 0
const IRON = 1
const COAL = 2
const COPPER = 3
const EMBER = 5

var object_grid: ObjectGrid = null
var ore_tiles: TileMap = null
var buried_ore_tiles: TileMap = null
var ground_tiles: TileMap = null
var drops: Node2D = null

const resource_drill = 1 # Drill amount needed to get resource
var amount_drilled = 0

@onready var turn_off_position = global_position
@onready var start_position = position

var particle_material: ParticleProcessMaterial

func _ready():
	object_grid = get_tree().root.get_node("Overworld/ObjectGrid")
	ore_tiles = get_tree().root.get_node("Overworld/OreTiles")
	buried_ore_tiles = get_tree().root.get_node("Overworld/BuriedOreTiles")
	ground_tiles = get_tree().root.get_node("Overworld/GroundTiles")
	drops = get_tree().root.get_node("Overworld/Drops")
	particle_material = $GPUParticles2D.process_material
	
	$GPUParticles2D.emitting = false


func _process(delta):
	$PointLight2D.energy = laser_heat + (1 - sin(timer / 2.0)) / 20
	$Line2D.width = laser_heat * (1 + sin(timer / 2.0) / 4)
	
	if !active:
		cool_down_laser()
	else:
		heat_up_laser()
	
	if object_grid != null && drilling:
		drill(delta)
	
	timer += 1


func heat_up_laser():
	if laser_heat < 1.0:
		laser_heat = lerp(laser_heat, 1.001, 0.5)
		if laser_heat > 1.0:
			drilling = true
			laser_heat = 1.0


func cool_down_laser():
	if laser_heat > 0.0:
		global_position = turn_off_position
		laser_heat = lerp(laser_heat, -0.001, 0.5)
		if laser_heat < 0.0:
			laser_heat = 0.0


func drill(delta):
	var drilled_block = null
	var tile_pos = null
	
	if $RayCast2D.is_colliding():
		drilled_block = $RayCast2D.get_collider().get_parent()
	else:
		tile_pos = object_grid.world_position_to_coord(global_position + $Line2D.points[1])
		drilled_block = object_grid.get_at(tile_pos)
	
	
	if drilled_block != null && drilled_block.has_method("damage"):
		drilled_block.damage(1)
		return
	
	if tile_pos == null:
		return
	
	amount_drilled += delta
	if amount_drilled > resource_drill:
		amount_drilled -= resource_drill
		
		var drilled_ore = -1
		var ore_tile_coord = buried_ore_tiles.get_cell_atlas_coords(0, tile_pos)
		
		var ground_tile = ground_tiles.get_cell_atlas_coords(0, tile_pos, false)
		var tile_above = ground_tiles.get_cell_atlas_coords(0, Vector2i(tile_pos + Vector2i.UP), false)
		var dug = false
		if ground_tile != Vector2i(3, 0) && ground_tile != Vector2i(-1, -1):
			dug = true
			if tile_above == Vector2i(3, 0) or tile_above == Vector2i(-1, -1):
				ground_tiles.erase_cell(0, Vector2i(tile_pos))
			else:
				ground_tiles.set_cell(0, Vector2i(tile_pos), 0, Vector2(3,0))
		
			if ground_tiles.get_cell_atlas_coords(0, Vector2i(tile_pos + Vector2i.DOWN), false) == Vector2i(3,0):
				ground_tiles.erase_cell(0, Vector2i(tile_pos + Vector2i.DOWN))
		
		if dug:
			ore_tile_coord = ore_tiles.get_cell_atlas_coords(0, tile_pos)
			ore_tiles.erase_cell(0, Vector2i(tile_pos))
		
		if ore_tile_coord != null:
			drilled_ore = ore_tile_coord.x
		
		var resource = null
		match drilled_ore:
			STONE:
				resource = Drop.create(StoneItem)
			IRON:
				resource = Drop.create(IronItem)
			COAL:
				resource = Drop.create(CoalItem)
			COPPER:
				resource = Drop.create(CopperItem)
			EMBER:
				resource = Drop.create(EmberItem)
		
		if resource == null:
			return
		
		resource.position = global_position + $Line2D.points[1]
		
		var direction = Vector2(0, 0)
		
		var behavior_grid: BehaviorGrid = get_tree().root.get_node("Overworld/BehaviorGrid")
		var cell = behavior_grid.world_position_to_coord(position)
		var behaviors = behavior_grid.get_at(cell)
		if behaviors != null:
			if behaviors.has("Vortex"):
				direction = (behaviors["Vortex"].center - position).normalized()
			elif behaviors.has("Wind"):
				direction = behaviors["Wind"].direction
			
			#Added variation
			direction = Vector2(direction.x + direction.y * randf_range(-0.15, 0.15), direction.y + direction.x * randf_range(-0.15, 0.15))
		else:
			direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		var speed = 100
		resource.apply_impulse(direction * speed)
		drops.add_child(resource)


func update_laser_effect(point: Vector2):
	if target_position != null:
		point = target_position.position
	
	$RayCast2D.target_position = point - position
	
	if $RayCast2D.is_colliding():
		var col_point = $RayCast2D.get_collision_point() - global_position
		var col_normal = $RayCast2D.get_collision_normal()
		$Line2D.points[1] = col_point
		$PointLight2D.position = col_point
		$GPUParticles2D.position = col_point
		particle_material.spread = 90
		particle_material.direction = Vector3(col_normal.x, col_normal.y, 0)
	else:
		$Line2D.points[1] = point - position
		$PointLight2D.position = point - position
		$GPUParticles2D.position = point - position
		particle_material.spread = 180
	
	$Line2D.width = lerpf($Line2D.width, 1, 0.5)


func turn_on_laser():
	turn_off_position = global_position
	$RayCast2D.target_position = Vector2.ZERO
	position = start_position
	active = true
	$Line2D.width = 0
	$PointLight2D.visible = true
	amount_drilled = 0


func fire_laser(point: Vector2 = Vector2.ZERO):
	update_laser_effect(point)


func turn_off_laser():
	active = false
	drilling = false
	turn_off_position = global_position
	cool_down_laser()
	$GPUParticles2D.emitting = false
