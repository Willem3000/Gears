extends Node2D

func generate_save() -> Dictionary:
	var save_dict = {
		"drops": [],
	}
	
	for drop: Drop in get_children():
		var drop_dict = {
			"drop_packed": drop.scene_file_path,
			"position": drop.position,
			"time": drop.time,
			"target": drop.target,
			"rotation": drop.rotation
		}
		save_dict["drops"].append(drop_dict)
	
	return save_dict

func parse_save(save_dict):
	for drop in save_dict["drops"]:
		var new_drop: Drop = load(drop["drop_packed"]).instantiate()
		
		new_drop.position = drop["position"]
		new_drop.time = drop["time"]
		new_drop.target = drop["target"]
		new_drop.rotation = drop["rotation"]
		
		add_child(new_drop)

func save_bin(save_game: FileAccess):
	var save_dict = generate_save()
	save_game.store_var(save_dict)

func load_bin(save_dict):
	parse_save(save_dict)
