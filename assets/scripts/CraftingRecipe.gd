extends Node

class_name CraftingRecipe

@export var craftable: InventoryItem:
	set(value):
		craftable = value

@export_group("Recipe")
@export var ingredients: Array[Ingredient]

func craft() -> InventoryItem:
	return craftable
