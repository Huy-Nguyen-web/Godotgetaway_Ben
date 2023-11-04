extends Node

var tiles = []
var cafe_spots = []
var map_size = Vector2()

var number_of_parked_cars = 30
var number_of_billboards = 13
var number_of_traffic_cones = 20
var number_of_hydrants = 50
var number_of_streetlights = 30
var number_of_ramps = 20
var number_of_scaffolding = 20
var number_of_cafes = 20
var number_of_beacons = 20
var number_of_ducks = 13

var player_list
var player_position = []



signal cop_spawn
signal spawn_players


func spawn_props(tile_list, size, plazas):
	tiles = tile_list
	cafe_spots = plazas
	map_size = size
	place_cars()
	place_billboards()
	place_traffic_cones()
	place_hydrants()
	place_streetlights()
	place_scaffolding()
	place_cafes()
	place_beacon()
	place_ducks()


func random_tile(tile_count):
	var tile_list = tiles
	var selected_tiles = []
	tile_list.shuffle() # Randomize the components in the list (random index)
	for i in range(tile_count):
		var tile = tile_list[i]
		selected_tiles.append(tile)
	return selected_tiles


func place_cars():
	var tile_list = random_tile(number_of_parked_cars + number_of_ramps)
	for i in range(number_of_parked_cars):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile.x, 0, tile.z)
		var allowed_rotation = $ObjectRotationLookUp.lookup_rotation(tile_type)
		if not allowed_rotation == null:
			var tile_rotation = allowed_rotation[randi()%allowed_rotation.size() - 1] * -1
			tile.y = tile.y + 0.5 # Adjust the height of the car
			rpc("spawn_cars", tile, tile_rotation)
		tile_list.pop_front()
	place_ramps(tile_list)


sync func spawn_cars(tile, car_rotation):
	var car = preload("res://Props/ParkedCars.tscn").instance()
	car.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	car.rotation_degrees.y = car_rotation
	add_child(car, true)


func place_billboards():
	var tile_list = random_tile(number_of_billboards)
	for i in range(number_of_billboards):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile.x, 0, tile.z)
		var allowed_rotation = $ObjectRotationLookUp.lookup_rotation(tile_type)
		if not allowed_rotation == null:
			var tile_rotation = allowed_rotation[randi()%allowed_rotation.size() - 1] * -1
			tile.y = tile.y + 0.5 # Adjust the height of the car
			rpc("spawn_billboards", tile, tile_rotation)
		tile_list.pop_front()

sync func spawn_billboards(tile, billboard_rotation):
	var billboard = preload("res://Props/Billboards/Billboard.tscn").instance()
	billboard.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	billboard.rotation_degrees.y = billboard_rotation
	add_child(billboard, true)



func place_traffic_cones():
	var tile_list = random_tile(number_of_traffic_cones)
	for i in range(number_of_traffic_cones):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile.x, 0, tile.z)
		var allowed_rotation = $ObjectRotationLookUp.lookup_rotation(tile_type)
		if not allowed_rotation == null:
			var tile_rotation = allowed_rotation[randi()%allowed_rotation.size() - 1] * -1
			tile.y = tile.y + 0.5 # Adjust the height of the car
			rpc("spawn_traffic_cones", tile, tile_rotation)
		tile_list.pop_front()

sync func spawn_traffic_cones(tile, traffic_cones_rotation):
	var traffic_cone = preload("res://Props/Cone/TrafficCones.tscn").instance()
	traffic_cone.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	traffic_cone.rotation_degrees.y = traffic_cones_rotation
	add_child(traffic_cone, true)
	
func place_hydrants():
	var tile_list = random_tile(number_of_hydrants)
	for i in range(number_of_hydrants):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile.x, 0, tile.z)
		var allowed_rotation = $ObjectRotationLookUp.lookup_rotation(tile_type)
		if not allowed_rotation == null:
			var tile_rotation = allowed_rotation[randi()%allowed_rotation.size() - 1] * -1
			tile.y = tile.y + 0.5 # Adjust the height of the car
			rpc("spawn_hydrants", tile, tile_rotation)
		tile_list.pop_front()

sync func spawn_hydrants(tile, hydrants_rotation):
	var hydrant = preload("res://Props/Hydrant/Hydrant.tscn").instance()
	hydrant.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	hydrant.rotation_degrees.y = hydrants_rotation
	add_child(hydrant, true)


func place_streetlights():
	var tile_list = random_tile(number_of_streetlights)
	for i in range(number_of_streetlights):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile.x, 0, tile.z)
		var allowed_rotation = $ObjectRotationLookUp.lookup_rotation(tile_type)
		if not allowed_rotation == null:
			var tile_rotation = allowed_rotation[randi()%allowed_rotation.size() - 1] * -1
			tile.y = tile.y + 0.5 # Adjust the height of the car
			rpc("spawn_streetlights", tile, tile_rotation)
		tile_list.pop_front()

sync func spawn_streetlights(tile, streetlights_rotation):
	var streetlight = preload("res://Props/StreetLight/StreeLight.tscn").instance()
	streetlight.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	streetlight.rotation_degrees.y = streetlights_rotation
	add_child(streetlight, true)
	
	
func place_ramps(tile_list):
	for i in range(number_of_ramps):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile.x, 0, tile.z)
		var allowed_rotation = $ObjectRotationLookUp.lookup_rotation(tile_type)
		if not allowed_rotation == null:
			var tile_rotation = allowed_rotation[randi()%allowed_rotation.size() - 1] * -1
			tile.y = tile.y + 0.5 # Adjust the height of the car
			rpc("spawn_ramps", tile, tile_rotation)
		tile_list.pop_front()


sync func spawn_ramps(tile, ramp_rotation):
	var ramp = preload("res://Props/Dumpsters/Dumpster.tscn").instance()
	ramp.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	ramp.rotation_degrees.y = ramp_rotation
	add_child(ramp, true)


func place_scaffolding():
	var tile_list = random_tile(number_of_scaffolding)
	for i in range(number_of_scaffolding):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile.x, 0, tile.z)
		var allowed_rotation = $ObjectRotationLookUp.lookup_rotation(tile_type)
		if not allowed_rotation == null:
			var tile_rotation = allowed_rotation[randi()%allowed_rotation.size() - 1] * -1
			tile.y = tile.y + 0.5 # Adjust the height of the car
			rpc("spawn_scaffolding", tile, tile_rotation)
		tile_list.pop_front()

sync func spawn_scaffolding(tile, scaffolding_rotation):
	var scaffolding = preload("res://Props/ScaffoldPole/Scaffolding.tscn").instance()
	scaffolding.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	scaffolding.rotation_degrees.y = scaffolding_rotation
	add_child(scaffolding, true)

func place_cafes():
	cafe_spots.shuffle()
	for i in range(number_of_cafes):
		var tile = cafe_spots[i]
		var building_rotation = tile[0]
		var tile_position = Vector3(tile[1], 0.5, tile[2])
		var tile_rotation = 0
		
		if building_rotation == 10:
			tile_rotation = 180
		elif building_rotation == 16:
			tile_rotation = 90
		elif building_rotation == 22:
			tile_rotation = 270
			
		rpc("spawn_cafes", tile_position, tile_rotation)
		
		
sync func spawn_cafes(tile, cafe_rotation):
	var cafe = preload("res://Props/Cafe/Cafe.tscn").instance()
	cafe.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	cafe.rotation_degrees.y = cafe_rotation
	add_child(cafe, true)


func place_beacon():
	var tile_list = random_tile(number_of_beacons + 5)
	# The last beacon is going to be the goal
	for i in range(number_of_beacons):
		var tile = tile_list[0]
		rpc("spawn_beacons", tile)
		tile_list.pop_front() # Pop the first one, so every later tile will be the first tile

	rpc("spawn_goal", tile_list[0])
	for i in range (1, 5):
		# Spawn player location using their local id
		var position = Vector3((tile_list[i].x * 20) + 10, tile_list[i].y, (tile_list[i].z * 20) + 10)
		player_position.append(position)
	
	emit_signal("spawn_players", player_position)
	

sync func spawn_beacons(tile):
	var beacon = preload("res://Beacon/Beacon.tscn").instance()
	beacon.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	add_child(beacon, true)
	

sync func spawn_goal(tile):
	var goal = preload("res://Beacon/Goal.tscn").instance()
	goal.translation = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
	add_child(goal, true)
	emit_signal("cop_spawn", goal.translation)



func place_ducks():
	var tile_list = random_tile(number_of_ducks)
	for i in range(number_of_ducks):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile.x, 0, tile.z)
		var allowed_rotation = $ObjectRotationLookUp.lookup_rotation(tile_type)
		if not allowed_rotation == null:
			var tile_rotation = allowed_rotation[randi()%allowed_rotation.size() - 1] * -1
			tile.y = tile.y + 0.5 # Adjust the height of the car
			rpc("spawn_ducks", tile, tile_rotation)
		tile_list.pop_front()

sync func spawn_ducks(tile, tile_rotation):
	var ducks = preload("res://Props/LemonDuck/lemon_duck.tscn").instance()
	ducks.translation = Vector3((tile.x * 20) + 50, tile.y, (tile.z * 20) + 50)
	ducks.rotation_degrees.y = tile_rotation
	add_child(ducks, true)

#sync func spawn_players(tile):
#	var position = Vector3((tile.x * 20) + 10, tile.y, (tile.z * 20) + 10)
#	emit_signal("spawn_players", position)
	

