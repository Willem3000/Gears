extends Node2D

#IDEA: Oil up for efficiency

var layout = [	[B.ROT|B.MID|B.DR, 			B.NA, B.NA],
				[B.ROT|B.MID|B.DR|B.TR|B.R, B.OCC|B.ALL_COLL, B.TUB|B.L],
				[B.ROT|B.MID|B.TR, 			B.NA, B.NA]]

@onready var item = load("res://assets/nodes/inventoryItems/EngineItem.tres")

var item_name:
	get:
		return item.item_name

@export var heat_ramp: GradientTexture1D

var fuel: float = 0.0:
	set(value):
		fuel = value
		update_heat_effect()
		reset()

# Variable used for smooth animations relying on fuel
var smooth_fuel: float = 0.0
var heat_sin_t: float = 0.0

var rotation_target = 0


func _ready():
	$Breakable.dropped_items.append(item)
	$Breakable.broken.connect(detach)
	$Placeable.connect("object_placed", _on_object_placed)
	$Rotary.rotation_speed = 0
	update_heat_effect()
	$MachinePart.highlight_color_changed.connect(set_highlight_color)


func set_highlight_color(color):
	$AnimatedSprite2D.material.set_shader_parameter("highlight_color",color)


func damage(dmg):
	var breakable = $Breakable
	breakable.damage(dmg)


func update_heat_effect():
	$EngineHeat.modulate = heat_ramp.gradient.sample((smooth_fuel + 0.5) / 50)
	$FullPointLight2D.radius = min(.349, smooth_fuel / 30.0)
	$FullPointLight2D.intensity = min(5.0, smooth_fuel / 5.0) * (1.0 + sin(heat_sin_t) * 0.1)
	heat_sin_t += 0.1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	burn_fuel(delta)
	
	$Rotary.rotation_speed += sign(rotation_target - $Rotary.rotation_speed) * 0.25

func burn_fuel(delta):
	smooth_fuel = lerpf(smooth_fuel, fuel, 0.2)
	if fuel > 0.0:
		fuel = max(0.0, fuel - delta)

func add_fuel(added_fuel):
	fuel += added_fuel

func _on_object_placed():
	$Rotary.rotation_speed = 0
	
	var object_grid = get_tree().root.get_node("Overworld/ObjectGrid")
	var connected_objects = object_grid.get_connected(self)
	
	for object in connected_objects:
		$MachinePart.attach(object.find_child("MachinePart"))
	
	$MachinePart.restart_machine()

func detach():
	$Rotary.rotation_speed = 0
	$MachinePart.detach()
	while fuel > 10.0:
		var coal_item = load("res://assets/nodes/inventoryItems/CoalChunkItem.tres")
		var drops = get_tree().root.get_node("Overworld/Drops")
		var coal_drop = Drop.create(coal_item)
		
		coal_drop.position = position
		drops.add_child(coal_drop)
		fuel -= 10.0

func reset():
	if fuel == 0:
		rotation_target = 0
	else:
		rotation_target = 6


func interact_with_item(other: InventoryItem):
	var other_name = other.item_name
	match other_name:
		"Coal Chunk":
			add_fuel(10.0)
			return true
	
	return false
	

func _on_rotary_changed_rotation():
	$MachinePart.restart_machine()
	if $Rotary.rotation_speed > 0:
		$AnimatedSprite2D.play()
	$AnimatedSprite2D.speed_scale = ($Rotary.rotation_speed / 6)


func rotate_clockwise(refresh = true):
	#TODO: Turn the garbage below in a proper matrix rotation
	var rotated_layout = [	[B.NA, B.NA, B.NA],
							[B.NA, B.NA, B.NA],
							[B.NA, B.NA, B.NA]]
	
	rotated_layout[0][2] = B.rotate_mask(layout[0][0], 2) # TL TO TR
	rotated_layout[0][0] = B.rotate_mask(layout[0][2], 2) # TR TO TL
	rotated_layout[1][2] = B.rotate_mask(layout[1][0], 4) # L TO R
	rotated_layout[1][0] = B.rotate_mask(layout[1][2], 4) # R TO L
	rotated_layout[2][2] = B.rotate_mask(layout[2][0], 6) # DL TO DR
	rotated_layout[2][0] = B.rotate_mask(layout[2][2], 6) # DR TO DL
	
	rotated_layout[1][1] = B.rotate_mask(layout[1][1], 4)
	
	layout = rotated_layout
	
	if refresh:
		detach()
		SignalManager.refresh_object.emit(self)
	
	$AnimatedSprite2D.scale *= Vector2(-1,1)
	$StaticBody2D.scale *= Vector2(-1,1)
	$EngineHeat.scale *= Vector2(-1,1)


func interact_with(other: Node2D):
	var other_name = other.get_parent().item_name
	
	match other_name:
		"Small Cog", "Drill", "Wall Drill", "Fan", "Tube Fan":
			var small_cog = other.get_parent()
			var small_cog_rotary = small_cog.find_child("Rotary")
			
			if small_cog_rotary.rotation_speed == 0:
				small_cog_rotary.rotation_speed = -$Rotary.rotation_speed
			elif $Rotary.rotation_speed == 0:
				$Rotary.rotation_speed = -small_cog_rotary.rotation_speed
			elif small_cog_rotary.rotation_speed != $Rotary.rotation_speed * -1:
				return false
			
			return true

	return false

func parse_save(save_dict):
	fuel = save_dict["fuel"]
	if save_dict.has("layout"):
		var saved_layout = save_dict["layout"]
		
		while layout != saved_layout:
			rotate_clockwise(false)

func generate_save() -> Dictionary:
	var save_dict = {
		"packed_path": scene_file_path,
		"fuel": fuel,
		"layout": layout
	}
	
	return save_dict
