extends CanvasLayer

func _ready():
	visible = true
	SignalManager.activate_loading_screen.connect(activate)
	deactivate()


func activate():
	$ColorRect.mouse_filter = 0
	$AnimationPlayer.play("ShowLoadingScreen")


func deactivate():
	$ColorRect.mouse_filter = 2
	$AnimationPlayer.play_backwards("ShowLoadingScreen")


func _on_animation_player_animation_finished(anim_name):
	if $AnimationPlayer.current_animation_position == 0:
		pass
	else:
		SignalManager.loading_screen_activated.emit()
