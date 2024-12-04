extends LineEdit


var mouse_over = false
var focused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if focused and Input.is_action_just_pressed("click") and not mouse_over:
		release_focus()
		SignalManager.unlock_input.emit()


func _on_focus_entered():
	SignalManager.lock_input.emit()
	focused = true


func _on_mouse_entered():
	mouse_over = true


func _on_mouse_exited():
	mouse_over = false
