extends Node2D

signal changed_rotation

@export var rotation_speed: float:
	set(value):
		if rotation_speed != value:
			rotation_speed = value
			changed_rotation.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if abs(rotation_speed) > 0:
		if get_parent().find_child("Sprite2D") != null:
			get_parent().find_child("Sprite2D").rotate(rotation_speed * delta)
		
		if get_parent().find_child("SpriteStack") != null:
			get_parent().find_child("SpriteStack").rotate_stack(rotation_speed * delta)
