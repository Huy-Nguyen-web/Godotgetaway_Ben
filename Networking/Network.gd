extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 8888
const MAX_PLAYERS = 4

var local_player_id = 0
var selected_port
var selected_ip
var ready_players = 0
var is_cop = false
var cops_paint
var robber_paint
var environment
var start_position
var goal


var city_size = Vector2()
# All players and player_data must be the same accross the network, so we need to 
sync var players = {}
sync var player_data = {}

signal player_disconnected
signal server_disconnected

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	
	print(IP.get_local_addresses())
	
func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(selected_port, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	add_to_player_list()
	


func connect_to_server():
	var peer = NetworkedMultiplayerENet.new()
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	peer.create_client(selected_ip, selected_port)
	get_tree().set_network_peer(peer)
	
	

func add_to_player_list():
	local_player_id = get_tree().get_network_unique_id()
	player_data = SaveGame.save_data # Get the information from the save data file (json file)
	players[local_player_id] = player_data # Create a unique key in the dictionary, and store the player data in there
	players[local_player_id]["is_cop"] = is_cop
	players[local_player_id]["robber_paint"] = robber_paint
	players[local_player_id]["cops_paint"] = cops_paint
	players[local_player_id]["start_position"] = start_position

func _connected_to_server():
	# This function will run from the client
	# Tell the local client to store their own data in the players list.
	add_to_player_list()
	
	# Remotely public tell other client to receive the data
	### TRY: Instead of using rpc, why not using rpc_id(1, args)
#	rpc("_send_player_info", local_player_id, player_data)
	rpc_id(1, "_send_player_info", local_player_id, player_data, is_cop)
	

func _on_player_disconnected(id):
	# Function to call when player is disconnected from the server
	players.erase(id)
	rset("players", players)
	if not has_node("/root/World"):
		rpc("update_waiting_room")
#	else:
#		if has_node("/root/World/LoadingScreen"):
#			# If player is still in the loading screen
#			game_ended()

	
remote func _send_player_info(id, player_info, cop_mode):
	players[id] = player_info
	players[id]["is_cop"] = cop_mode
#	if local_player_id == 1: 
		# Only server will send the data to all client
	rset("players", players)
	rpc("update_waiting_room")

func _on_player_connected(id):
	if not get_tree().is_network_server():
		print(str(id) + " has connected")


sync func update_waiting_room():
	get_tree().call_group("WaitingRoom", "refresh_players", players)
	
	
func start_game():
	rpc("load_world", environment, goal)
	
	
sync func load_world(selected_environment, money):
	environment = selected_environment
	goal = money
	get_tree().change_scene("res://World/World.tscn")
	

func set_player_position(random_position):
	var player_id_list = Array(players.keys())
	for i in player_id_list.size():
		rpc("set_remote_position", player_id_list[i], random_position[i])

	
sync func set_remote_position(player_id, position):
	players[player_id]["start_position"] = position


func end_game():
	if local_player_id == 1:
		rpc("game_ended")
	else:
		game_ended()


func disconnect_from_server():
	if not get_tree().is_network_server():
		get_tree().disconnect("connected_to_server", self, "_connected_to_server")
	else:
		ready_players = 0

	hide_waiting_room()
	players = {}
	get_tree().network_peer = null



sync func hide_waiting_room():
	get_tree().call_group("WaitingRoom", "hide")



sync func game_ended():
	if has_node("/root/World"):
		get_node("/root/World").queue_free()
	
	# Reset audio
		
	# Change back to lobby scene
	get_tree().change_scene("res://Lobby/Lobby.tscn")
	
	# Disconnect network signal
	if not get_tree().is_network_server():
		get_tree().disconnect("connected_to_server", self, "_connected_to_server")

	ready_players = 0
	players = {}
	get_tree().network_peer = null
	
	
func _on_server_disconnected():
	if not has_node("/root/World"):
		disconnect_from_server()
	else:
		game_ended()
	
