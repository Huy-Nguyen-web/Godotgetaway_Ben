extends Popup


var resolutions = {
	"1920x1080": Vector2(1920, 1080),
	"1280x720": Vector2(1280, 720),
	"1024x600": Vector2(1024, 600),
	"800x600": Vector2(800, 600)
}


func _ready():
	var reflection = $VBoxContainer/CenterContainer/GridContainer/ReflectionCheck
	var particles = $VBoxContainer/CenterContainer/GridContainer/ParticlesCheck
	var distance = $VBoxContainer/CenterContainer/GridContainer/DistanceCheck
	var shadow = $VBoxContainer/CenterContainer/GridContainer/ShadowCheck
	var resolution = $VBoxContainer/CenterContainer/GridContainer/ResolutionSelection
	var full_screen = $VBoxContainer/CenterContainer/GridContainer/FullScreenCheck
	
	reflection.pressed = SaveGame.save_data["reflection"]
	particles.pressed = SaveGame.save_data["particles"]
	distance.pressed = SaveGame.save_data["far_cam"]
	shadow.pressed = SaveGame.save_data["shadow"]
	for i in resolutions.keys().size():
		if resolutions.keys()[i] == SaveGame.save_data["resolution"]:
			resolution.selected = i
	full_screen.pressed = SaveGame.save_data["full_screen"]

func _on_DoneButton_pressed():
	hide()


func _on_ReflectionCheck_toggled(button_pressed):
	get_tree().call_group("Cameras", "reflections", button_pressed)


func _on_ParticlesCheck_toggled(button_pressed):
	get_tree().call_group("Particles", "manage_particles", button_pressed)


func _on_DistanceCheck_toggled(button_pressed):
	get_tree().call_group("Cameras", "far_cam", button_pressed)


func _on_ShadowCheck_toggled(button_pressed):
	get_tree().call_group("Cameras", "shadow", button_pressed)



func _on_FullScreenCheck_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	SaveGame.save_data["full_screen"] = button_pressed
	SaveGame.save_game()


func _on_ResolutionSelection_item_selected(index):
	var current_resolution
	match index:
		0:
			OS.set_window_size(Vector2(1920, 1080))
			current_resolution = "1920x1080"
		1:
			OS.set_window_size(Vector2(1280, 720))
			current_resolution = "1280x720"
		2:
			OS.set_window_size(Vector2(1024, 600))
			current_resolution = "1024x600"
		3:
			OS.set_window_size(Vector2(800, 600))
			current_resolution = "800x600"
	
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,SceneTree.STRETCH_ASPECT_KEEP, resolutions[current_resolution])
	SaveGame.save_data["resolution"] = current_resolution
	
	SaveGame.save_game()
