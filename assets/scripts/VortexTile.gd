extends ITileBehavior

class_name VortexTile

const packed: PackedScene = preload("res://assets/nodes/behaviours/VortexTile.tscn")

var center: Vector2:
	set(value):
		center = value

var speed: float:
	set(value):
		speed = value

static func new_tile(_tile_position, _center, _speed):
	var vortex_tile: VortexTile = packed.instantiate()
	vortex_tile.tile_name = "Vortex"
	vortex_tile.tile_position = _tile_position
	vortex_tile.center = _center
	vortex_tile.speed = _speed
	
	return vortex_tile

func combine(behaviour: ITileBehavior):
	if behaviour is VortexTile:
		speed += behaviour.speed

func seperate(behaviour: ITileBehavior):
	if behaviour is VortexTile:
		speed -= behaviour.speed

func is_active():
	return speed > 0
	
func update_particles():
	$GPUParticles2D.rotation = global_position.angle_to_point(center)
