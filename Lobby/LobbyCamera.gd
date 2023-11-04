extends Camera

func _ready():
	check_saved_setting()


func change_environment(new_environment):
	environment = load(new_environment)



func check_saved_setting():
	if SaveGame.save_data["far_cam"]:
		far = 600
	else:
		far = 200
		
	environment.ss_reflections_enabled = SaveGame.save_data["reflection"]
	environment.ssao_enabled = SaveGame.save_data["reflection"]
	get_tree().call_group("ManageShadow", "set_shadow", SaveGame.save_data["shadow"])


func reflections(value):
	environment.ss_reflections_enabled = value
	environment.ssao_enabled = value
	SaveGame.save_data["reflection"] = value
	SaveGame.save_game()


func shadow(value):
	get_tree().call_group("ManageShadow", "set_shadow", value)
	SaveGame.save_data["shadow"] = value
	SaveGame.save_game()
	
	
func far_cam(value):
	if value:
		far = 600
	else:
		far = 250
	
	SaveGame.save_data["far_cam"] = value
	SaveGame.save_game()
