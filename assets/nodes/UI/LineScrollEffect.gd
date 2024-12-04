extends Panel


func _process(delta):
	var height = position.y + 0.25
	if height > 20:
		height -= 20
	position = Vector2(position.x, height)
