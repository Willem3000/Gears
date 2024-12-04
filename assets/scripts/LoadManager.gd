extends Node

var OverworldEmpty = preload("res://assets/scenes/OverworldTemplate.tscn")
var LoadingScreen = preload("res://assets/nodes/UI/LoadingScreen.tscn")

func new_game():
	if get_tree().root.has_node("Overworld"):
		get_tree().root.get_node("Overworld").queue_free()
		await get_tree().root.get_node("Overworld").tree_exited
	
	if get_tree().root.has_node("MainMenu"):
		get_tree().root.get_node("MainMenu").queue_free()
		await get_tree().root.get_node("MainMenu").tree_exited
	
	var new_overworld_instance = OverworldEmpty.instantiate()
	get_tree().root.add_child(new_overworld_instance)


func load_game(save_game: String = ""):
	assert(save_game != "" or save_game != null, "Save game path corrupted.")
	
	if !DirAccess.dir_exists_absolute("user://save"):
		return false
	
	var save_game_path = "user://save/" + save_game + ".save"
	
	if get_tree().root.has_node("Overworld"):
		get_tree().root.get_node("Overworld").queue_free()
		await get_tree().root.get_node("Overworld").tree_exited
	
	if get_tree().root.has_node("MainMenu"):
		get_tree().root.get_node("MainMenu").queue_free()
		await get_tree().root.get_node("MainMenu").tree_exited
	
	var empty_overworld_instance: Overworld = OverworldEmpty.instantiate()
	get_tree().root.add_child(empty_overworld_instance)
	empty_overworld_instance.save_game_path = save_game_path
