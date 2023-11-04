extends Popup


func _ready():
	$CenterContainer/VBoxContainer/VolumeControl/GridContainer/CenterContainer/MasterVolumeSlider.value = SaveGame.save_data["master_volume"]
	$CenterContainer/VBoxContainer/VolumeControl/GridContainer/CenterContainer2/SFXVolumeSlider.value = SaveGame.save_data["sfx_volume"]
	$CenterContainer/VBoxContainer/VolumeControl/GridContainer/CenterContainer3/MusicVolumeSlider.value = SaveGame.save_data["music_volume"]


func _on_Button_pressed():
	hide()


func _on_MasterVolumeSlider_value_changed(value):
	VolumeControl.update_master_volume(value)


func _on_SFXVolumeSlider_value_changed(value):
	VolumeControl.update_sfx_volume(value)


func _on_MusicVolumeSlider_value_changed(value):
	VolumeControl.update_music_volume(value)


func _on_BackToMenuButton_pressed():
	Network.end_game()
