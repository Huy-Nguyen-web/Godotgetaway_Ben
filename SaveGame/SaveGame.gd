extends Node

var default_data = {"Player_name" : "Unnamed",
					"IP": "127.0.0.1",
					"Port": 8888,
					"master_volume": -10,
					"music_volume": -10,
					"sfx_volume": -10,
					"reflection": false,
					"shadow": false,
					"particles": false,
					"far_cam": false,
					"resolution": "1920x1080",
					"full_screen": true}
var save_data = {}
var content
var data

const SAVEGAME = "user://Savegame.json"


func _ready():
	save_data = get_data()


#function to get data
func get_data():
	# Create a new file object
	var file = File.new()
	if not file.file_exists(SAVEGAME):
		save_data = default_data
		save_game()
		file.open(SAVEGAME, File.READ)
		content = file.get_as_text()
		data = parse_json(content)
	else:
		file.open(SAVEGAME, File.READ)
		content = file.get_as_text()
		data = parse_json(content)
		for key in default_data.keys():
			if not data.has(key):
				data[key] = default_data[key]
		save_data = data
	# Read the file
	
	# get the content of the file
	
	# parse the data
	file.close()
	return data
	
	
func save_game():
	var save_game = File.new()
	save_game.open(SAVEGAME, File.WRITE)
	save_game.store_line(to_json(save_data))
