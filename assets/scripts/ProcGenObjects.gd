@tool
extends Node2D

var wall_packed = preload("res://assets/nodes/grid_objects/walls/Wall.tscn")

@export var noise: FastNoiseLite

@export var refresh_trigger: bool:
	set(value):
		refresh_trigger = value
		refresh()

@export var frequency: float = 0.01:
	set(value):
		frequency = value
		generate_noise()

@export var octaves: int = 5:
	set(value):
		octaves = value
		generate_noise()

@export var lacunarity: float = 2:
	set(value):
		lacunarity = value
		generate_noise()

@export var gain: float = 0.5:
	set(value):
		gain = value
		generate_noise()

@export var weighted_strength: float = 0.0:
	set(value):
		weighted_strength = value
		generate_noise()


const WIDTH = 64
const HEIGHT = 64


func _ready():
	refresh()


func refresh():
	clear()
	generate_noise()
	generate_tiles()

func clear():
	for child in get_children():
		if child.name != "Hub":
			remove_child(child)

func generate_noise():
	randomize()
	noise = FastNoiseLite.new()
	noise.frequency = frequency
	noise.fractal_octaves = octaves
	noise.fractal_lacunarity = lacunarity
	noise.fractal_gain = gain
	noise.fractal_weighted_strength = weighted_strength
	noise.seed = randi()

func generate_tiles():
	for x in WIDTH:
		for y in HEIGHT:
			if x > WIDTH / 2 - 5 && x < WIDTH / 2 + 5 && y > HEIGHT / 2 - 5 && y < HEIGHT / 2 + 5:
				continue
			
			var noise_sample = (noise.get_noise_2d(x, y) + 1.0) / 2.0
			var object = get_object(noise_sample)
			if object != null:
				object.position = Vector2(x * 16 - 16 * WIDTH / 2 + 8, y * 16 - 16 * HEIGHT / 2 + 8)
				add_child(object)

func get_object(noise_sample):
	if 0.5 > noise_sample:
		return wall_packed.instantiate()

	return null
