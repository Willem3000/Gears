@tool
class_name SpriteStack extends Node2D

@export var height_gap: float:
	set(value):
		height_gap = value
		var total_height = 0
		for child in get_children():
			child.position = Vector2(0, total_height)
			total_height += height_gap

func rotate_stack(angle: float):
	for child in get_children():
		child.rotate(angle)

func set_stack_rotation(angle: float):
	for child in get_children():
		child.rotation = angle

func set_highlight_color(color: Vector3):
	for child: Sprite2D in get_children():
		child.material.set_shader_parameter("highlight_color",color)
	
