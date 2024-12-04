extends Camera2D

@export var follow: Node2D

var start_offset = offset

var shake_timer = 0
var shake_strength = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.set_screen_shake.connect(set_screen_shake)
	SignalManager.set_local_screen_shake.connect(set_local_shake)
	position = follow.position
	for i in 2:
		await get_tree().process_frame
	position_smoothing_enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = follow.position
	
	if shake_timer > 0:
		apply_screen_shake(delta)


func apply_screen_shake(delta):
	shake_timer -= delta
	shake_strength *= min(1, shake_timer / 0.1)
	offset = random_offset()


func set_screen_shake(shake, duration):
	shake_strength = shake
	shake_timer = duration


func set_local_shake(shake, duration, shake_position):
	var distance = position.distance_to(shake_position)
	var shake_multiplier = (300 - distance) / 300
	shake *= shake_multiplier
	set_screen_shake(shake, duration)


func random_offset() -> Vector2:
	var shake = [-shake_strength, shake_strength]
	var x = shake[randi() % len(shake)]
	var y = shake[randi() % len(shake)]
	
	return start_offset + Vector2(x, y)
