extends CharacterBody2D

class_name Robot

@onready var object_grid: ObjectGrid = get_tree().root.get_node("Overworld/ObjectGrid")

var input_locked = false

var x_input = 0
var y_input = 0

@export var move_speed = 200

var input_look_direction: Vector2 = Vector2(0,1)
var look_direction = 2*PI

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.lock_input.connect(lock_input)
	SignalManager.unlock_input.connect(unlock_input)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	x_input = 0
	y_input = 0
	
	if !input_locked:
		handle_input()
	
	if Input.is_action_just_pressed("pause"):
		SignalManager.toggle_pause_menu.emit()
	
	move(delta)
	
	input_look_direction = input_look_direction.normalized()
	look_direction = lerp_angle(look_direction, input_look_direction.angle() + -PI/2, 0.6)
	
	$SpriteStack.set_stack_rotation(look_direction)
	$SpriteStackShadow.set_stack_rotation(look_direction)
	
	hover()


func move(delta):
	velocity = Vector2(x_input, y_input).normalized() * move_speed
	move_and_slide()
	#position = Vector2(round(position.x), round(position.y))
	
	if velocity.length() > 0:
		$HoverSound2D.volume_db = lerpf($HoverSound2D.volume_db, -30.0, 0.14)
	else:
		$HoverSound2D.volume_db = lerpf($HoverSound2D.volume_db, -70.0, 0.07)


func hover():
	$SpriteStack.position.y = round(sin(Time.get_ticks_msec() / 100))


func handle_input():
	if Input.is_action_pressed("left"):
		x_input -= 1
		input_look_direction += Vector2(-1,0)
	
	if Input.is_action_pressed("right"):
		x_input += 1
		input_look_direction += Vector2(1,0)
		
	if Input.is_action_pressed("up"):
		y_input -= 1
		input_look_direction += Vector2(0,-1)
	
	if Input.is_action_pressed("down"):
		y_input += 1
		input_look_direction += Vector2(0,1)
	
	if Input.is_action_just_pressed("inventory"):
		SignalManager.toggle_inventory.emit()
	
	if Input.is_action_pressed("vacuum"):
		use_vacuum()
	
	if Input.is_action_just_pressed("right_click"):
		$Laser.turn_on_laser()
	
	if Input.is_action_pressed("right_click"):
		use_laser()
	
	if Input.is_action_just_released("right_click"):
		$Laser.turn_off_laser()
	
	if Input.is_action_just_pressed("rotate"):
		SignalManager.rotate_object.emit()
	
	if Input.is_action_just_pressed("DEBUG_spawn"):
		SignalManager.spawn_drop.emit()


func lock_input():
	input_locked = true


func unlock_input():
	input_locked = false


func use_vacuum():
	var drops = get_tree().root.get_node("Overworld/Drops")
	for drop in drops.get_children():
		if drop is Drop:
			var distance = position.distance_to(drop.position)
			if distance > 5 && distance < 60:
				if !drop.in_tube:
					drop.apply_force((position - drop.position) * (500/(max(4,distance-8))))
			elif distance <= 5:
				var drop_item = drop.inventory_item
				drop.queue_free()
				add_to_inventory(drop_item)


func use_laser():
	$Laser.fire_laser(get_local_mouse_position())


func add_to_inventory(item: InventoryItem):
	$PickUpDropSound2D.pitch_scale = 1.0 + randf_range(-0.5, 0.5)
	$PickUpDropSound2D.play()
	SignalManager.add_to_inventory.emit(item)


func _on_hover_sound_2d_finished():
	$HoverSound2D.play()


func generate_save() -> Dictionary:
	var save_dict = {
		"position": position,
		"look_direction": look_direction,
	}
	
	return save_dict


func parse_save(save_dict):
	position = save_dict["position"]
	look_direction = save_dict["look_direction"]


func save_bin(save_game: FileAccess):
	var save_dict = generate_save()
	save_game.store_var(save_dict)
