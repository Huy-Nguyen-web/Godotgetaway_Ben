extends Popup

func _ready():
	if has_node("/root/World"):
		$CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/BackToMenuButton.show()
	else:
		$CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/BackToMenuButton.hide()
		


func _on_AudioButton_pressed():
	$AudioMenu.popup_centered()


func _on_VideoButton_pressed():
	$VideoMenu.popup_centered()


func _on_DoneButton_pressed():
	hide()


func _on_BackToMenuButton_pressed():
	Network.end_game()


func _on_Button_pressed():
	$InputMenu.popup_centered()
