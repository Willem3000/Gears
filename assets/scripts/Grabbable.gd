class_name Placeable extends Node2D

# Component class which makes objects grabbable with the cursor

signal object_placed
	
func release():
	object_placed.emit()
