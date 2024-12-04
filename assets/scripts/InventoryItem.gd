extends Resource

class_name InventoryItem

@export var item_name: String = ""
@export var packed: PackedScene = null
@export var icon: Texture2D = null
@export var quantity: int = 1


static func create(_name: String, _packed: Resource, _icon: Resource, _quantity: int = 1):
	var item = InventoryItem.new()
	item.item_name = _name
	item.packed = _packed
	item.icon = _icon
	item.quantity = _quantity
	return item

func to_object() -> Node2D:
	if packed != null:
		var object = packed.instantiate()
		return object
	
	return null

func from_object(object: Node2D):
	item_name = object.item_name
	packed = object.packed
	icon = object.icon
