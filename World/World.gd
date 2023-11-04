extends Spatial

var player = preload("res://Player/Player.tscn")
var money_stashed = 0
var money_recovered = 0

var cop_spawn

var random_position = []

export var criminal_victory_score = 3000
export var cop_victory_score = 3000

onready var players_list = $Players

func _enter_tree():
	get_tree().paused = true


func _input(event):
	if event.is_action_pressed("menu"):
		$InGameMenu.visible = !$InGameMenu.visible



func _ready():
	get_tree().set_refuse_new_network_connections(true)
	criminal_victory_score = Network.goal
	cop_victory_score = Network.goal
	AudioServer.set_bus_mute(3, false)
	
	
func spawn_local_player():
	var new_player = player.instance()
	new_player.name = str(Network.local_player_id) # Tell the player child to change the name to 12315403... (a number)
	new_player.translation = Vector3(10, 0.5, 20)
	players_list.add_child(new_player)
	
	if new_player.is_in_group("Player"):
		yield(get_tree(), "idle_frame")
		new_player.translation = Network.players[Network.local_player_id]["start_position"]
#	if Network.is_cop:
#		yield(get_tree(), "idle_frame")
#		new_player.translation = cop_spawn
	
		
	
remote func spawn_remote_player(player_id):
	var new_player = player.instance()
	new_player.translation = Vector3(10, 0.5, 20)
	new_player.name = str(player_id)
	players_list.add_child(new_player)
	
	if new_player.is_in_group("Player"):
		yield(get_tree(), "idle_frame")
		new_player.translation = Network.players[int(player_id)]["start_position"]
#	if new_player.is_in_group("cops"):
#		yield(get_tree(), "idle_frame")
#		new_player.translation = cop_spawn


func set_player_position():
	print(players_list.get_child_count())
	for i in range(players_list.get_child_count()):
#		players_list.get_child(i).translation = random_position[i]
		var player_id = players_list.get_child(i).name
		var position = random_position[i]
		rpc("set_remote_position", players_list.get_child(i).name, random_position[i])


sync func set_remote_position(player_id, position):
	print(player_id)

	players_list.get_node(str(player_id)).translation = position

	
func unpause():
	get_tree().paused = false
	spawn_local_player()
	rpc("spawn_remote_player", Network.local_player_id)
		
	if Network.environment == "res://Environment/night.tres":
		$Sun.queue_free()
	else:
		get_tree().call_group("lights", "queue_free")


remote func update_gamestate(stashed, recovered):
	if Network.local_player_id == 1:
		money_stashed += stashed
		money_recovered += recovered
		update_gui(money_stashed, criminal_victory_score)
		check_win_condition()
	else:
		rpc_id(1, "update_gamestate", stashed, recovered)


func update_gui(money, goal):
	rpc("update_remote_gui", money, goal)
	
	
sync func update_remote_gui(money, goal):
	get_tree().call_group("GUI", "update_money", money, goal)
	


func check_win_condition():
	if money_stashed >= criminal_victory_score:
#		get_tree().call_group("Announcement", "victory", true)
		rpc("criminal_win")
		
		
sync func criminal_win():
	get_tree().call_group("EndGame", "victory", true)
		
#	elif money_stashed >= cop_victory_score:
#		get_tree().call_group("Announcement", "victory", false)


func _on_ObjectSpawner_cop_spawn(location):
	cop_spawn = location


func _on_ObjectSpawner_spawn_players(player_position):
	random_position = player_position
	Network.set_player_position(random_position)





