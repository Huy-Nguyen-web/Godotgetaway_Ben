extends Node

var configfile
var filepath = "res://keybinds.ini"

var keybinds = {}

func _ready():
	configfile = ConfigFile.new()
	if configfile.load(filepath) == OK:
		for key in configfile.get_section_keys("keybinds"):
			var key_value = configfile.get_value("keybinds", key)
			print(key, ":", OS.get_scancode_string(key_value))
			
			keybinds[key] = key_value
			
	set_game_binds()
			

func set_game_binds():
	for key in keybinds.keys():
		var value = keybinds[key]
		
		var action_list = InputMap.get_action_list(key)
		if !action_list.empty():
			InputMap.action_erase_event(key, action_list[0])
			
		var new_key = InputEventKey.new()
		new_key.set_physical_scancode(value)
		InputMap.action_add_event(key, new_key)


func write_config():
	for key in keybinds.keys():
		var key_value = keybinds[key]
		configfile.set_value("keybinds", key, key_value)
	configfile.save(filepath)
