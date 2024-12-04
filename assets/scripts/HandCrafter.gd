extends Control


@export var recipes: Node
@export var inventory: Inventory
@export var external_inventory: Inventory

var is_open = false


func _ready():
	SignalManager.toggle_inventory.connect(toggle)
	update_ui()
	close()
	$AnimationPlayer.stop()


func toggle():
	if is_open:
		close()
	else:
		open()


func open():
	is_open = true
	$AnimationPlayer.stop()	
	$AnimationPlayer.speed_scale = 3
	$AnimationPlayer.play("OpenHandCrafter")
	pass


func close():
	is_open = false
	$AnimationPlayer.speed_scale = 4	
	$AnimationPlayer.play_backwards("OpenHandCrafter")
	pass


func update_ui():
	$RecipeContainer.empty()
	for recipe in recipes.get_children():
		$RecipeContainer.add_recipe(recipe)


func can_craft(recipe: CraftingRecipe) -> bool:
	for ingredient: Ingredient in recipe.ingredients:
		var amount = inventory.has_item(ingredient.item, ingredient.quantity)
		if amount > 0:
			if external_inventory == null || external_inventory.has_item(ingredient.item, ingredient.quantity) > 0:
				$CraftingResultSound.stream = load("res://assets/sound/sound_effects/CraftingFailed.wav")
				$CraftingResultSound.pitch_scale = randf_range(0.8, 1.2)
				$CraftingResultSound.play()
				print("Insufficient crafting ingredients")
				return false
	
	return true

func craft(recipe):
	for ingredient in recipe.ingredients:
		var amount = ingredient.quantity
		amount = inventory.remove_item(ingredient.item, ingredient.quantity)
		if amount > 0:
			if external_inventory == null || external_inventory.remove_item(ingredient.item, ingredient.quantity) > 0:
				return false
	
	var item = recipe.craft()
	$CraftingResultSound.stream = load("res://assets/sound/sound_effects/CraftingSuccess.wav")
	$CraftingResultSound.pitch_scale = randf_range(0.9, 1.1)
	$CraftingResultSound.play()
	inventory.add_item(item)

func _on_recipe_container_selected_crafting_slot(recipe):
	if can_craft(recipe):
		craft(recipe)
