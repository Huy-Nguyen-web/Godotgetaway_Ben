extends CSGBox

func _ready():
	load_material()
	

func load_material():
	var selected_material = pick_random_material()
	if Network.local_player_id == 1:
		rpc("display_material", selected_material)


sync func display_material(poster_material):
	material = load(poster_material)


func pick_random_material():
	var material_list = get_files("res://Props/Billboards/BillboardMaterials/")
	var selected_material = material_list[randi() % material_list.size()]
	return selected_material
	
	
func get_files(folder):
	var gathered_files = {}
	var file_count = 0
	var dir = Directory.new()
	
	dir.open(folder)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			gathered_files[file_count] = folder + file
			file_count += 1
	
	return gathered_files
