extends Control

func save_game(save_game: String = ""):
	assert(save_game != "" or save_game != null, "Save game path corrupted.")
	
	if !DirAccess.dir_exists_absolute("user://save"):
		DirAccess.make_dir_absolute("user://save")
	
	var save_game_path = "user://save/" + save_game + ".save"
	
	var save: FileAccess = FileAccess.open(save_game_path, FileAccess.WRITE)
	var persistent_nodes = get_tree().get_nodes_in_group("Persistent")
	for node in persistent_nodes:
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			return
		
		# Check the node has a save function.
		if !node.has_method("save_bin"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			return
 
		node.save_bin(save)


func delete_save(save_game: String = ""):
	assert(save_game != "" or save_game != null, "Save game path corrupted.")
	
	if !DirAccess.dir_exists_absolute("user://save"):
		DirAccess.make_dir_absolute("user://save")
	
	var save_game_path = "user://save/" + save_game + ".save"
	DirAccess.remove_absolute(save_game_path)
