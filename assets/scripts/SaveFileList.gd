extends ItemList

func refresh_save_list():
	clear()
	
	var delete_icon = load("res://assets/sprites/DeleteIcon.png")
	
	if !DirAccess.dir_exists_absolute("user://save"):
		DirAccess.make_dir_absolute("user://save")
	
	var save_dir = DirAccess.open("user://save")
	
	for file_name in save_dir.get_files():
		file_name = file_name.substr(0, len(file_name) - 5)
		add_item(file_name)
	
	if item_count == 0:
		add_item("No save files!", null, false)
