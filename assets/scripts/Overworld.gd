class_name Overworld extends Node2D

var save_game_path = "":
	set(value):
		if value != "":
			save_game_path = value
			load_overworld(save_game_path)


func load_overworld(save_game_path: String):
	var save_game: FileAccess = FileAccess.open(save_game_path, FileAccess.READ)
	var persistent_nodes = get_tree().get_nodes_in_group("Persistent")
	for node in persistent_nodes:
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			return
		
		# Check the node has a save function.
		if !node.has_method("parse_save"):
			print("persistent node '%s' is missing a parse_save() function, skipped" % node.name)
			return
 		
		node = node.parse_save(save_game.get_var())
