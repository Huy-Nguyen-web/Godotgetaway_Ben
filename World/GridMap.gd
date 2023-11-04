extends GridMap

const N = 1
const E = 2
const S = 4
const W = 8

var width
var height # This is in a 2D Dimension
var spacing = 3 # How many tile we need to move to change the direction

var erase_fraction = 0.25 # percentage of erasing chance

var random_position = []

var cell_walls = {Vector3(0, 0, -spacing): N, Vector3(spacing, 0, 0): E,
		Vector3(0, 0, spacing): S, Vector3(-spacing, 0, 0): W} # What do we removing when we making maps

var plaza_tile = [17, 20, 22, 25]
var cafe_spots = []

onready var players_list = get_node("../Players")

func _ready():
	clear()
	if Network.local_player_id == 1:
		# Only if this machine is a host, make a map
		randomize()
		get_map_settings()
		make_map()
		record_tile_position()
		rpc("send_ready")


func get_map_settings():
	width = Network.city_size.x
	height = Network.city_size.y


func make_map():
	make_blank_map()
	make_map_border()
	make_maze()
	erase_walls()
	

func record_tile_position():
	var tiles = []
	for x in range(0, width):
		for z in range(0, height):
			var current_cell = Vector3(x, 0, z)
			var current_tile_type = get_cell_item(current_cell.x, 0, current_cell.z)
			if current_tile_type < 15:
				tiles.append(current_cell)
			elif current_tile_type in plaza_tile:
				var building_rotation = get_cell_item_orientation(current_cell.x, 0, current_cell.z)
				var plaza_location = [building_rotation, x, z]
				cafe_spots.append(plaza_location)
	var map_size = Vector2(width, height)
	$ObjectSpawner.spawn_props(tiles, map_size, cafe_spots)

	
func make_blank_map():
	for x in width:
		for z in height:
			var building = pick_building(x, z)
			var possible_rotation = [0, 10, 16, 22]
			var building_rotation = possible_rotation[randi() % possible_rotation.size() - 1]
#			set_cell_item(x, 0, z, building, possible_rotation[randi() % possible_rotation.size() - 1])
			rpc("place_cell", x, z, building, building_rotation)


func make_map_border():
	$Border.resize_border(cell_size.x, width) # Assume this is a square map


func pick_building(x, z):
	var chance_of_skyscrapper = 1
	var chance_of_special_buildings = 5
	
	var skyscrapper = 16
	var special_buildings = [19, 24, 27]
	
	var neighbour_1 = [17, 18]
	var neighbour_2 = [20, 21]
	var neighbour_3 = [22, 23]
	var neighbour_4 = [25, 26]
	
	var possible_building = []
	
	
	if x >= width/2 and z >= height/2:
		possible_building = neighbour_2
	elif x >= width/2 and z <= height/2:
		possible_building = neighbour_3
	elif x <= width/2 and z >= height/2:
		possible_building = neighbour_4
	elif x <= width/2 and z <= height/2:
		possible_building = neighbour_1
	
	
	var building
	var random_chance = (randi()%99) + 1
	if random_chance <= chance_of_skyscrapper:
		building = skyscrapper
	else:
		if random_chance <= chance_of_special_buildings:
			if possible_building == neighbour_1:
				building = special_buildings[0]
			elif possible_building == neighbour_3:
				building = special_buildings[1]
			elif possible_building == neighbour_4:
				building = special_buildings[2]
			else:
				building = possible_building[randi() % possible_building.size() - 1]
		else:
			building = possible_building[randi() % possible_building.size() - 1]
	return building


func check_neighbour(cell, unvisited):
	# Make maze will have a list called unvisited
	# This function will take the cell as an input, and check whether or not
	# the cell is unvisited
	
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited: 
			# Check in all 4 direction to see around it, if tile is unvisited
			# Put that into a list
			list.append(cell + n)
	
	return list		


func make_maze():
	var unvisited = []
	var stack = []
	
	for x in range(0, width, spacing):
		for z in range(0, height ,spacing):
			unvisited.append( Vector3(x, 0, z) )

	var current = Vector3.ZERO # Which tile are we in right now, start with position Vector3(0, 0, 0)
	unvisited.erase(current) # The current position is now visited, so erase it
	
	while unvisited:
		var neighbours = check_neighbour(current, unvisited)
		
		if neighbours.size() > 0:
			var next
			if current == Vector3.ZERO:
				next = Vector3(0, 0, spacing)
			else:
				next = neighbours[randi() % neighbours.size()] # Go to a random next neighbour tile
			stack.append(current)
			
			
			var dir = next - current # What is the direction of the road go (N, E, W or S) in Vector3
			
			# Get the current cell item, and substract the cell in that direction
			
			var current_walls = min(get_cell_item(current.x, 0, current.z), 15) - cell_walls[dir]
			var next_walls = min(get_cell_item(next.x, 0, next.z), 15) - cell_walls[-dir]
			
#			set_cell_item(current.x, 0, current.z, current_walls, 0)
			rpc("place_cell", current.x, current.z, current_walls, 0)
#			set_cell_item(next.x, 0, next.z, next_walls, 0)
			rpc("place_cell", next.x, next.z, next_walls, 0)
			fill_gaps(current, dir)
			
			current = next
			unvisited.erase(current)
		
		elif stack:
			current = stack.pop_back()


func fill_gaps(current, dir):
	# What type of tile will be put down
	var tile_type
	
	for i in range(1, spacing):
		if dir.x > 0: # Heading east
			tile_type = 5
			current.x += 1
		elif dir.x < 0: # Heading west
			tile_type = 5
			current.x -=1
		elif dir.z > 0: # Heading south
			tile_type = 10
			current.z += 1
		elif dir.z < 0: # Heading north
			tile_type = 10
			current.z -= 1
#		set_cell_item(current.x, 0, current.z, tile_type, 0)
		rpc("place_cell", current.x, current.z, tile_type, 0)

func erase_walls():
	for i in range(width * height * erase_fraction):
		var x = int(rand_range(1, (width-1)/spacing)) * spacing
		var z = int(rand_range(1, (height-1)/spacing)) * spacing
		var cell = Vector3(x, 0, z)
		var current_cell = get_cell_item(cell.x, cell.y, cell.z)
		var neighbour = cell_walls.keys()[randi() % cell_walls.size()]

		if current_cell & cell_walls[neighbour]:
			var walls = current_cell - cell_walls[neighbour]
			walls = clamp(walls, 0, 15)
			
			
			var neighbour_walls = get_cell_item(cell.x + neighbour.x, 0, cell.z + neighbour.z) - cell_walls[-neighbour]
			neighbour_walls = clamp(neighbour_walls, 0, 15)
			
#			set_cell_item(cell.x, 0, cell.z, walls, 0)
			rpc("place_cell", cell.x, cell.z, walls, 0)
#			set_cell_item(cell.x + neighbour.x, 0, cell.z + neighbour.z, neighbour_walls, 0)
			rpc("place_cell", cell.x + neighbour.x, cell.z + neighbour.z, neighbour_walls, 0)
			fill_gaps(cell, neighbour)
			
			
sync func place_cell(x, z, cell, cell_rotation):
	set_cell_item(x, 0, z, cell, cell_rotation)
	


sync func send_ready():
	if Network.local_player_id == 1:
		player_ready()
	else:
		rpc_id(1, "player_ready")
	
	
remote func player_ready():
	Network.ready_players += 1
	rpc("update_loading_screen", Network.ready_players, Network.players.size())
	if Network.ready_players == Network.players.size():
		rpc("send_go")
	
	
	
sync func update_loading_screen(players_num, max_players):
	get_tree().call_group("LoadingScreen", "update_loading_screen", players_num, max_players)



	
sync func send_go():
	get_tree().call_group("LoadingScreen", "start_game")
	get_tree().call_group("gamestate", "unpause")


