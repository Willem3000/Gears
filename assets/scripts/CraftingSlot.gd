extends Panel

@export var recipe: CraftingRecipe:
	set(value):
		recipe = value
		if recipe != null:
			$TextureRect.texture = recipe.craftable.icon


func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		if event.button_index == 1:
			if Input.is_action_pressed("shift"):
				SignalManager.add_to_inventory.emit(recipe.craft())
			else:
				get_parent().selected_crafting_slot.emit(recipe)
		elif event.button_index == 2:
			for i in 5:
				get_parent().selected_crafting_slot.emit(recipe)
	
	if event is InputEventMouseMotion:
		$RecipeDescription.global_position = get_global_mouse_position()


func craft() -> InventoryItem:
	return recipe.craft_item()


func _on_mouse_exited():
	$RecipeDescription.visible = false


func _on_mouse_entered():
	$RecipeDescription.visible = true
	$RecipeDescription.clear()
	$RecipeDescription.size = Vector2($RecipeDescription.size.x,0)
	$RecipeDescription.add_item(recipe.craftable.item_name)
	for ingredient: Ingredient in recipe.ingredients:
		$RecipeDescription.add_item(str(ingredient.quantity, " ", ingredient.item.item_name), ingredient.item.icon)
