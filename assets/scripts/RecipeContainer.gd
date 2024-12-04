extends GridContainer

@onready var CraftingSlot = load("res://assets/nodes/UI/CraftingSlot.tscn")

signal selected_crafting_slot(slot)

func add_recipe(recipe: CraftingRecipe):
	var slot = CraftingSlot.instantiate()
	slot.recipe = recipe
	add_child(slot)


func empty():
	for child in get_children():
		child.queue_free()
