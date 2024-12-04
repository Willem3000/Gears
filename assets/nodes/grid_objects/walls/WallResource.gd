class_name WallResource extends Resource

const item_name = "Wall"

@export var sprite: Texture = load("res://assets/sprites/WallPlaceholder.png")
@export var dropped_items: Array[InventoryItem] = []
@export var indestructable: bool = false
@export var total_health: float = 10.0
