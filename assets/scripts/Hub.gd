extends Node2D

const item_name = "Hub"

const layout = [[B.OCC|B.ALL_COLL|B.TUB, 	B.OCC|B.ALL_COLL, 		B.OCC|B.ALL_COLL|B.TUB],
				[B.OCC|B.ALL_COLL, 			B.OCC|B.ALL_COLL, 		B.OCC|B.ALL_COLL],
				[B.OCC|B.ALL_COLL|B.TUB, 	B.OCC|B.ALL_COLL, 		B.OCC|B.ALL_COLL|B.TUB]]

@onready var packed = load(scene_file_path)
@onready var icon = load("res://assets/sprites/Hub.png")

func detach():
	$MachinePart.detach()


func reset():
	pass


func interact_with(other: Node2D):
	var other_name = other.get_parent().item_name

	match other_name:
		"Tube":
			pass

	return true


func _on_button_button_down():
	$Sprite2D.region_rect = Rect2(52, 0, 52, 52)


func _on_button_button_up():
	$Sprite2D.region_rect = Rect2(0, 0, 52, 52)


func _on_button_pressed():
	$HubMenu.toggle()

func interact_with_item(other: InventoryItem):
	$HubMenu.add_item(other)

func generate_save() -> Dictionary:
	var save_dict = {
		"packed_path": scene_file_path,
		"hub_menu": $HubMenu.generate_save()
	}
	
	return save_dict

func parse_save(save_dict):
	$HubMenu.parse_save(save_dict["hub_menu"])

func save_bin(save_game: FileAccess):
	var save_dict = generate_save()
	save_game.store_var(save_dict)
