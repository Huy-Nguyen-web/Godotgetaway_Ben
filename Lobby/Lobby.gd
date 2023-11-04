extends CanvasLayer

onready var name_text_box = $VBoxContainer/CenterContainer/GridContainer/NameTextBox
onready var ip_text_box = $VBoxContainer/CenterContainer/GridContainer/IPTextBox
onready var port_text_box = $VBoxContainer/CenterContainer/GridContainer/PortTextBox
onready var button = $VBoxContainer/CenterContainer/GridContainer/TeamCheck
onready var environment_button = $VBoxContainer/CenterContainer/GridContainer/TimeCheck
onready var color_picker = $VBoxContainer/CenterContainer/GridContainer/ColorPickerButton


var is_cop = false
var city_size
var play_tween = true
var environment = "res://Environment/night.tres"
var is_host = false
var goal

var resolution = {
	"1920x1080": Vector2(1920, 1080),
	"1280x720": Vector2(1280, 720),
	"1024x600": Vector2(1024, 600),
	"800x600": Vector2(800, 600)
}


func _ready():
	print("Hello World")

	OS.set_window_size(resolution[SaveGame.save_data["resolution"]])
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT,SceneTree.STRETCH_ASPECT_KEEP, resolution[SaveGame.save_data["resolution"]])
	OS.window_fullscreen = SaveGame.save_data["full_screen"]
#	get_tree().set_refuse_new_network_connections(false)
	name_text_box.text = SaveGame.save_data["Player_name"]
	ip_text_box.text = SaveGame.save_data["IP"]
	port_text_box.text = str(SaveGame.save_data["Port"])
	button.select(0, true)
	environment_button.select(0, true)
	_on_CitySizePicker_item_selected(1)
	_on_Money_item_selected(1)
	color_picker.color = $LobbyBackground.robber_paint.albedo_color
	get_tree().call_group("HostOnly", "hide")
	get_tree().call_group("ClientOnly", "show")
	for i in range(3, 7):
		AudioServer.set_bus_mute(i, true)

func host_game():
	Network.selected_port = int(port_text_box.text)
	Network.selected_ip = ip_text_box.text
	Network.is_cop = is_cop
	Network.create_server()
	Network.environment = environment
	Network.city_size = city_size
	Network.goal = goal
	get_tree().call_group("HostOnly", "show")
	create_waiting_room()


func join_game():
	Network.selected_port = int(port_text_box.text)
	Network.selected_ip = ip_text_box.text
	Network.is_cop = is_cop
	Network.connect_to_server()
	create_waiting_room()


func _on_NameTextBox_text_changed(new_text):
	SaveGame.save_data["Player_name"] = name_text_box.text
	# Rewrite the data
	SaveGame.save_game()


func _on_IPTextBox_text_changed(new_text):
	SaveGame.save_data["IP"] = ip_text_box.text
	SaveGame.save_game()


func _on_PortTextBox_text_changed(new_text):
	SaveGame.save_data["Port"] = port_text_box.text
	SaveGame.save_game()


func create_waiting_room():
	$WaitingRoom.popup_centered()
	$WaitingRoom.refresh_players(Network.players)


func _on_StartButton_pressed():
	Network.start_game()


func _on_TeamCheck_toggled(button_pressed):
	is_cop = button_pressed


func _on_TeamCheck_item_selected(index):
	if (not int(is_cop) == index) and (play_tween == true):
		play_tween = false
		button.set_item_disabled(0, true)
		button.set_item_disabled(1, true)
		is_cop = index
		if is_cop:
			color_picker.color = $LobbyBackground.cops_paint.albedo_color
		else:
			color_picker.color = $LobbyBackground.robber_paint.albedo_color

		$LobbyBackground.pivot()


func _on_Tween_tween_completed(object, key):
	play_tween = true
	button.set_item_disabled(0, false)
	button.set_item_disabled(1, false)


func _on_ColorPickerButton_color_changed(color):
	if not is_cop:
		$LobbyBackground.new_robber_color(color)
	else:
		$LobbyBackground.new_cops_color(color)


func _on_CitySizePicker_item_selected(index):
	match index:
		0:
			city_size = Vector2(15, 15)
		1:
			city_size = Vector2(20, 20)
		2:
			city_size = Vector2(40, 40)
		3: 
			city_size = Vector2(100, 100)


func _on_OptionsButton_pressed():
	$InGameMenu.popup_centered()
	
	
	

func _on_MasterVolumeSlider_value_changed(value):
	var icon1 = preload("res://GUI/Volume.svg")
	var icon2 = preload("res://GUI/Volume1.svg")
	if value > -25:
		$AudioButton.set_button_icon(icon1)
	else:
		$AudioButton.set_button_icon(icon2)
		


func _on_TimeCheck_item_selected(index):
	match index:
		0:
			environment = "res://Environment/night.tres"
		1:
			environment = "res://Environment/day.tres"
	
	get_tree().call_group("Cameras", "change_environment", environment)


func _on_Money_item_selected(index):
	match index:
		0:
			goal = 3000
		1:
			goal = 5000
		2:
			goal = 7000


func _on_PlayButton_pressed():
	if is_host:
		host_game()
	else:
		join_game()


func _on_OptionButton_item_selected(index):
	is_host = index
	if is_host:
		get_tree().call_group("HostOnly", "show")
		get_tree().call_group("ClientOnly", "hide")
	else:
		get_tree().call_group("HostOnly", "hide")
		get_tree().call_group("ClientOnly", "show")
	


func _on_QuitButton_pressed():
	get_tree().quit()
