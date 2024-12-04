extends Node2D

class_name Grid

@export var grid = {} # {Vector2i: {Node2D: int}}
var objects = {} # {Node2D: Vector2i}

var tile_size: int = 16

var hover_tile = Vector2i(0,0)

func set_hover_tile():
	var mouse_pos = get_global_mouse_position()
	hover_tile =  world_position_to_coord(mouse_pos)


func cell_to_world_position(cell: Vector2i) -> Vector2:
	var world_position = Vector2(	cell.x * tile_size + tile_size / 2,
									cell.y * tile_size + tile_size / 2)
	return world_position


func world_position_to_coord(world_pos: Vector2) -> Vector2i:
	var x: int = floor(world_pos.x / tile_size)
	var y: int = floor(world_pos.y / tile_size)
	
	return Vector2i(x, y)
