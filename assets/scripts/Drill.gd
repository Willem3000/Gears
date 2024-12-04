extends Node2D

const layout = [[B.NA, B.ROT|B.D, B.NA],
				[B.ROT|B.R, B.ROT|B.OCC|B.ALL_COLL, B.ROT|B.L],
				[B.NA, B.ROT|B.T, B.NA]]

@onready var item = load("res://assets/nodes/inventoryItems/DrillItem.tres")

var item_name:
	get:
		return item.item_name

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

const resource_drill = 18 # Drill amount needed to get resource
var amount_drilled = 0

var drilled_ore = -1

var drill_volume
var extract_volume = 0

var drops = null


func _ready():
	$Breakable.dropped_items.append(item)
	$Breakable.broken.connect(detach)
	$Placeable.connect("object_placed", _on_object_placed)
	drops = get_tree().root.get_node("Overworld/Drops")
	drill_volume = $DrillingSound.volume_db
	$Rotary.changed_rotation.connect(_on_rotation_changed)
	$GPUParticles2D.emitting = false
	$MachinePart.highlight_color_changed.connect(set_highlight_color)


func set_highlight_color(color):
	$SpriteStack.set_highlight_color(color)


func damage(dmg):
	var breakable = $Breakable
	breakable.damage(dmg)


func _physics_process(delta):
	drill(delta)


func _on_rotation_changed():
	if abs($Rotary.rotation_speed) > 0 && drilled_ore != -1:
		$GPUParticles2D.emitting = true
		drill_volume = -5
		match drilled_ore:
			STONE:
				set_particle_atlas_index(0)
				$GPUParticles2D.process_material.color_ramp = ParticleChunkRamp
			IRON:
				set_particle_atlas_index(1)
				$GPUParticles2D.process_material.color_ramp = ParticleChunkRamp
			COAL:
				set_particle_atlas_index(2)
				$GPUParticles2D.process_material.color_ramp = ParticleChunkRamp
			COPPER:
				set_particle_atlas_index(3)
				$GPUParticles2D.process_material.color_ramp = ParticleChunkRamp
			EMBER:
				set_particle_atlas_index(4)
				$GPUParticles2D.process_material.color_ramp = ParticleEmberRamp
	else:
		$GPUParticles2D.emitting = false
		drill_volume = -80


func set_particle_atlas_index(index):
	var particle_atlas: AtlasTexture = $GPUParticles2D.texture
	particle_atlas.region = Rect2(index * 2,0,2,2)
	$GPUParticles2D.texture = particle_atlas


func drill(delta):
	$DrillingSound.volume_db = lerpf($DrillingSound.volume_db, drill_volume, 0.05)
	
	var drill_speed = abs($Rotary.rotation_speed * delta)
	if drill_speed == 0 || drilled_ore == -1:
		return
	
	amount_drilled += drill_speed
	while amount_drilled > resource_drill:
		amount_drilled -= resource_drill
		extract_resource()


func extract_resource():
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
	
	resource.position = $OreSpawn.global_position
	
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
	

func _on_object_placed():
	var object_grid: ObjectGrid = get_tree().root.get_node("Overworld/ObjectGrid")
	var ore_tilemap: TileMap = get_tree().root.get_node("Overworld/OreTiles")
	var connected_objects = object_grid.get_connected(self)
	var tile_coord = ore_tilemap.get_cell_atlas_coords(0, object_grid.world_position_to_coord(position))
	if tile_coord != null:
		drilled_ore = tile_coord.x
	for object in connected_objects:
		$MachinePart.attach(object.find_child("MachinePart"))
	
	$MachinePart.restart_machine()


func detach():
	$Rotary.rotation_speed = 0
	$MachinePart.detach()


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
