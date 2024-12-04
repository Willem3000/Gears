@tool
class_name FullPointLight2D extends Node2D

@export var debug = false:
	set(value):
		debug = value
		queue_redraw()

@export_range(0.0, 1.0, 0.003921568) var radius: float = 1.0:
	set(value):
		radius = value
		if has_node("GroundLight") && has_node("ObjectLight"):
			$GroundLight.color = Color(radius, 1.0, 1.0)
			$ObjectLight.color = Color(radius, 1.0, 1.0)
		queue_redraw()

@export_range(0.0, 10.0, 0.01) var intensity: float = 1.0:
	set(value):
		intensity = value
		if has_node("GroundLight") && has_node("ObjectLight"):
			$GroundLight.energy = intensity
			$ObjectLight.energy = intensity
		queue_redraw()

func _draw() -> void:
	if debug:
		draw_circle(global_position, radius * $GroundLight.texture.get_width() * 5.6, Color.MAGENTA, true)
