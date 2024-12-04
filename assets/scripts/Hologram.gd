extends Node2D

const HOLO_HEIGHT = -1
var speed = 0

var active = false
var target_position: Vector2 = Vector2(0,0)

func _process(delta):
	if active && target_position != position:
		speed = position.distance_to(target_position) * 5
		position = lerp(position,position + (target_position - position).normalized() * speed, 0.1)

func turn_off():
	if active:
		active = false

func turn_on():
	if !active:
		active = true
		position = target_position
	
func set_hologram(hologram: Node2D):
	for child in get_children():
		child.queue_free()
	
	if hologram == null:
		turn_off()
		return
	
	turn_on()

	add_child(hologram)
	hologram.position += Vector2(0, HOLO_HEIGHT)
	
	if hologram is Sprite2D or hologram is AnimatedSprite2D:
		hologram.modulate = Color(hologram.modulate, 0.5)
	elif hologram is SpriteStack:
		for sprite in hologram.get_children():
			sprite.modulate = Color(sprite.modulate, 0.5)
		
