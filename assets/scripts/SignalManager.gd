extends Node

# Cursor
signal selected_inventory_slot(slot)
signal selected_crafting_slot(slot)
signal selected_object_grid_cell(part)

# Camera
signal set_screen_shake(shake, duration)
signal set_local_screen_shake(shake, duration, global_position)

# Selectors
signal selected_object_grid
signal shift_selected_object_grid
signal hover_object_grid

# Menus
signal add_to_inventory(item)

# UI
signal toggle_inventory
signal toggle_pause_menu
signal activate_loading_screen
signal loading_screen_activated

# Robot
signal lock_input
signal unlock_input

# Modifiers
signal rotate_object
signal refresh_object(object)

# DEBUG
signal spawn_drop
