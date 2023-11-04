extends Popup


func victory(criminal_win):
	rpc("announce_victory", criminal_win)


sync func announce_victory(criminal_win):
	visible = true
	if criminal_win:
		$ColorRect/Label.text = "Criminal Team Win!"
	else:
		$ColorRect/Label.text = "Cops Team Win!"



func _on_BackToMenuButton_pressed():
	# Getting player back to menu
	for i in range(3, 7):
		AudioServer.set_bus_mute(i, true)

	Network.end_game()
