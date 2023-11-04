extends Popup

onready var player_list = $VBoxContainer/CenterContainer/ItemList

var cops_texture = preload("res://GUI/cop.svg")
var criminal_texture = preload("res://GUI/criminal.svg")

func _ready():
	player_list.clear()
	

func refresh_players(players):
	player_list.clear()
	for player_id in players:
		var player = players[player_id]["Player_name"] # Get the name of the player in the data
		if players[player_id]["is_cop"]:
			player_list.add_item(player, cops_texture, false)
		else:
			player_list.add_item(player, criminal_texture, false)

	var cops_num = count_cops(players)
	var robbers_num = count_robbers(players)
	if cops_num > 0 and robbers_num > 0:
		$CenterContainer/VBoxContainer/StartButton.disabled = false
	else:
		$CenterContainer/VBoxContainer/StartButton.disabled = true
	

func _on_BackButton_pressed():
	Network.disconnect_from_server()



func count_cops(players):
	var cops_num = 0
	for player_id in players:
		if players[player_id]["is_cop"]:
			cops_num += 1
	
	return cops_num
	
	
func count_robbers(players):
	var robber_num = 0
	for player_id in players:
		if not players[player_id]["is_cop"]:
			robber_num += 1
	
	return robber_num
