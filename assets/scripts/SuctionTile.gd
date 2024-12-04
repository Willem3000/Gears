extends ITileBehavior

class_name SuctionTile

const packed: PackedScene = preload("res://assets/nodes/behaviours/SuctionTile.tscn")

var direction: Vector2i:
	set(value):
		direction = value
		update_particles()

var speed: float:
	set(value):
		speed = value
		#update_particles()

static func new_tile(_tile_position, _direction, _speed):
	var wind_tile: SuctionTile = packed.instantiate()
	wind_tile.tile_name = "Suction"
	wind_tile.tile_position = _tile_position
	wind_tile.direction = _direction
	wind_tile.speed = _speed
	
	return wind_tile

func combine(behaviour: ITileBehavior):
	if behaviour is SuctionTile:
		speed += behaviour.speed

func seperate(behaviour: ITileBehavior):
	if behaviour is SuctionTile:
		speed -= behaviour.speed

func is_active():
	return speed > 0
	
func update_particles():
	var particle_direction = Vector2(direction).angle()
	$GPUParticles2D.rotation = particle_direction
