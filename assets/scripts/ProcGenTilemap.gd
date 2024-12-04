@tool
extends TileMap

@export var noise: FastNoiseLite

@export var refresh_trigger: bool:
	set(value):
		refresh_trigger = value
		refresh()

@export var layered: bool = true:
	set(value):
		layered = value
		refresh()

@export var tile_count: int = 1

@export var offset: Vector2 = Vector2.ZERO:
	set(value):
		offset = value
		refresh()

@export var frequency: float = 0.01:
	set(value):
		frequency = value
		refresh()

@export_range(0, 30, 1) var octaves: int = 5:
	set(value):
		octaves = value
		refresh()

@export var contrast: float = 1:
	set(value):
		contrast = value
		refresh()

@export var lacunarity: float = 2:
	set(value):
		lacunarity = value
		refresh()

@export var gain: float = 0.5:
	set(value):
		gain = value
		refresh()

@export var weighted_strength: float = 0.0:
	set(value):
		weighted_strength = value
		refresh()


@export var tile_gradient: Gradient:
	set(value):
		tile_gradient = value
		refresh()

@export var source_id: int = 0

@export var seed: int = -1:
	set(value):
		seed = value
		refresh()


const WIDTH = 64
const HEIGHT = 64

const TILES = {
	"EMPTY": 0,
	"CRACK1": 1,
	"CRACK2": 2
}

func _ready():
	refresh()
	


func refresh():
	clear()
	generate_noise()
	generate_tiles()

func generate_noise(seed_offset: int = 0):
	randomize()
	noise = FastNoiseLite.new()
	noise.offset = Vector3(offset.x, offset.y, 0)
	noise.frequency = frequency
	noise.fractal_octaves = octaves
	noise.fractal_lacunarity = lacunarity
	noise.fractal_gain = gain
	noise.fractal_weighted_strength = weighted_strength
	if seed == -1:
		noise.seed = randi()
	else:
		noise.seed = seed + seed_offset

func generate_tiles():
	if layered:
		for i in tile_count:
			generate_noise(i)
			for x in WIDTH:
				for y in HEIGHT:
					var noise_sample = ((noise.get_noise_2d(x, y) + 1.0) / 2.0) * contrast
					var tile_index = -1
					if 1 > noise_sample:
						tile_index = i
					
					if tile_index > -1:
						var alternative = TileSetAtlasSource.TRANSFORM_FLIP_H * randi_range(0,2) + TileSetAtlasSource.TRANSFORM_FLIP_V * randi_range(0,2)
						set_cell(0, Vector2i(x - WIDTH / 2, y - HEIGHT / 2), source_id, Vector2(tile_index, 0), alternative)
	else:
		for x in WIDTH:
			for y in HEIGHT:
				var noise_sample = ((noise.get_noise_2d(x, y) + 1.0) / 2.0) * contrast
				var tile_index = Vector2(get_tile_index(noise_sample),0)
				if tile_index.x > -1:
					var alternative = TileSetAtlasSource.TRANSFORM_FLIP_H * randi_range(0,2) + TileSetAtlasSource.TRANSFORM_FLIP_V * randi_range(0,2)
					set_cell(0, Vector2i(x - WIDTH / 2, y - HEIGHT / 2), source_id, tile_index, alternative)

func get_tile_index(noise_sample):
	if tile_gradient != null:
		for i in tile_gradient.get_point_count():
			if tile_gradient.get_offset(i) > noise_sample:
				return i

	return -1
