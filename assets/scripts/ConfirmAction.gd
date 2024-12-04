extends Control

signal confirm(type)

var confirmation_type: int = 0

func _ready():
	turn_off()

func turn_on(msg = "", type = 0):
	$ConfirmMessage.text = msg
	confirmation_type = type
	visible = true


func turn_off():
	visible = false


func _on_cancel_button_pressed():
	turn_off()


func _on_confirm_button_pressed():
	confirm.emit(confirmation_type)
	turn_off()
