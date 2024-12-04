extends Node2D

signal changed_speed
signal changed_direction

var suction_speed: int:
	set(value):
		suction_speed = value
		changed_speed.emit()

var suction_direction: Vector2i:
	set(value):
		suction_direction = value
		changed_direction.emit()

func reset():
	suction_speed = 0
	#suction_direction = iVector2.ZERO
