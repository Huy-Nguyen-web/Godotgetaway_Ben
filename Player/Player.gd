extends VehicleBody

const MAX_STEER_ANGLE = 0.35
const STEER_SPEED = 1.5

const MAX_ENGINE_FORCE = 300
const MAX_BREAK_FORCE = 10
const MAX_SPEED = 30

var steer_target = 0.0 # Where I want the wheels to go
var steer_angle = 0.0 # Where are wheels now

var cops_color# Color just to test the color in game
var robber_color

var money = 0
var money_drop = 50
var money_per_beacon = 1000

var siren = false
var got_arrested = false

sync var players = {} # This one related to the networking stuff with the car
sync var local_player_position = null
var player_data = {"steer": 0, "engine": 0, "brakes": 0, 
				"position": null, "speed": 0, "money": 0, "siren": false, "arrest_value": 0}

export var max_arrest_value = 750
var arrest_value = 0
var criminal_detected = false

var player_spectate = 0


onready var active_players = get_parent()
onready var non_active_players = get_parent().get_parent().get_node("NonActivePlayers")

func _ready():
	join_team()
	label_car()
	paint_car()
	players[name] = player_data
	players[name].position = transform
	get_tree().call_group("GUI", "update_money", money, Network.goal)
	
	if not is_local_player():
#		$Camera.current = false
		$GUI.queue_free()
		$Arrow.queue_free()
	else:
		$Camera.make_current()


func join_team():
	if Network.players[int(name)]["is_cop"]:
		add_to_group("cops")
		collision_layer = 4
		$RobberMesh.queue_free()
		$Horn.queue_free()
		$DeleteTimer.queue_free()
		$PlayerBillboard/Viewport/TextureProgress.hide()
#		$CopMesh.name = "CarBody"
	else:
		add_to_group("robber")
		$CopMesh.queue_free()
		$Arrow.queue_free()
		$Siren.queue_free()
#		$RobberMesh.name = "CarBody"
	add_to_group("Player")

func label_car():
	if is_local_player():
		$PlayerBillboard/Viewport/PlayerLabel.queue_free()
	else:
		$PlayerBillboard/Viewport/PlayerLabel.text = Network.players[int(name)]["Player_name"]
		
	$PlayerBillboard/Viewport/TextureProgress.max_value = max_arrest_value

func paint_car():
	cops_color = Network.players[int(name)]["cops_paint"]
	robber_color = Network.players[int(name)]["robber_paint"]
	
	var cops_paint = SpatialMaterial.new()
	cops_paint.metallic_specular = 0.5
	cops_paint.albedo_color = cops_color
	cops_paint.roughness = 0.35
	$CopMesh.set_surface_material(0, cops_paint)

	var robber_paint = SpatialMaterial.new()
	
	
	
	robber_paint.metallic_specular = 0.5
	robber_paint.albedo_color = robber_color
	robber_paint.roughness = 0.35
	$RobberMesh.set_surface_material(0, robber_paint)


func is_local_player():
	# check if the player is local
	return name == str(Network.local_player_id)


func _physics_process(delta):
	if is_local_player():
		drive(delta)
		display_location()
		if Network.local_player_id == 1:
			update_position(name, transform)
		else:
			rpc_unreliable_id(1, "update_position", name, transform)
	
		
	else:
#		transform = players[name].position
		if players[name].position != null:
			$Tween.interpolate_property(self, "transform", transform, players[name].position, 0.2)
			$Tween.start()
	
		steering = players[name].steer
		engine_force = players[name].engine
		brake = players[name].brakes
	
	
	if is_in_group("cops"):
		check_siren_state()
	
	if criminal_detected:
		increment_arrest_value()
		


sync func update_position(player_id, position):
	players[player_id].position = position
	rset_unreliable("players", players)


func drive(delta):
#	var speed = players[name].speed
	var speed = linear_velocity.length()
	var steering_value = apply_steering(delta)
	var throttle = apply_throttle(speed)
	var brakes = apply_brake()
	var arrest_amount = arrest_value
	
	steering = steering_value
	engine_force = throttle
	brake = brakes
	update_server(name, steering_value, throttle, brakes, speed, arrest_amount)
	
	
func update_server(id, steering_value, throttle, brakes, speed, arrest_amount):
	if not Network.local_player_id == 1:
		# If you are not the host, then tell the host these message
		rpc_unreliable_id(1, "manage_clients", id, steering_value, throttle, brakes, speed, arrest_amount)
	else:
		manage_clients(id, steering_value, throttle, brakes, speed, arrest_amount)
	
	get_tree().call_group("Interface", "update_speed", speed)
	$Exhaust.update_particles(speed)
	
	
sync func manage_clients(id, steering_value, throttle, brakes, speed, arrest_amount):
	players[id].steer = steering_value
	players[id].engine = throttle
	players[id].brakes = brakes
#	players[id].position = transform
	players[id].speed = linear_velocity.length()
	players[id].arrest_value = arrest_amount
	rset_unreliable("players", players)
	
	
func apply_steering(delta):
	# Moving left and right
	var steer_val = 0
	var left = Input.get_action_strength("steer_left")
	var right = Input.get_action_strength("steer_right")
	
	if left:
		steer_val = left
	elif right:
		steer_val = -right
		
	steer_target = steer_val * MAX_STEER_ANGLE
	
	if steer_target < steer_angle:
		steer_angle -= STEER_SPEED * delta
	elif steer_target > steer_angle:
		steer_angle += STEER_SPEED * delta
		
	return steer_angle
	

func apply_throttle(speed):
	var throttle_val = 0
	var forward = Input.get_action_strength("forward")
	var back = Input.get_action_strength("back")
	
	if speed < MAX_SPEED:
		if back:
			throttle_val = -back
		elif forward:
			throttle_val = forward
		
	return throttle_val * MAX_ENGINE_FORCE


func apply_brake():
	var brake_val = 0.0
	var brake_strength = Input.get_action_strength("brake")
	
	if brake_strength:
		brake_val = brake_strength
	return brake_val * MAX_BREAK_FORCE


func display_location():
	var x = stepify(translation.x, 1)
	var z = stepify(translation.z, 1)
	
	$GUI/ColorRect/VBoxContainer/Location.text = str(x) + " - " + str(z)
	
func beacon_emptied():
	money += money_per_beacon
	if is_local_player():
		manage_money()


func manage_money():
	if Network.local_player_id == 1:
		update_money(name, money)
	else:
		rpc_id(1, "update_money", name, money)


remote func update_money(id, cash):
	players[name].money = cash
	rset("players", players)
	if name == "1":
		display_money(cash)
	else:
		rpc_id(int(id), "display_money", cash)


remote func display_money(cash):
	money = players[name].money

	$GUI/ColorRect/VBoxContainer/MoneyLabel/AnimationPlayer.play("MoneyPulse")
	$GUI/ColorRect/VBoxContainer/MoneyLabel.text = "$" + str(cash)


func money_delivered():
	var local_player_name = SaveGame.save_data["Player_name"]
	
	if is_local_player():
#			get_tree().call_group("Announcement", "money_stashed", local_player_name, money)
		announce_money_stashed(local_player_name, money)
		get_tree().call_group("gamestate", "update_gamestate", money, 0)
	
		money = 0
		manage_money()


func announce_money_stashed(player_name, stashed_money):
	rpc("remote_announce_money_stashed", player_name, stashed_money)


sync func remote_announce_money_stashed(player_name, stashed_money):
	get_tree().call_group("Announcement", "money_stashed", player_name, stashed_money)


func _on_Player_body_entered(body):
	if body.has_node("Money"):
		body.queue_free()
		money += money_drop
		if is_local_player():
			manage_money()
		if is_in_group("cops"):
			get_tree().call_group("gamestate", "update_gamestate", 0, money)
	elif money > 0 and not is_in_group("cops"):
		spawn_money()
		money -= money_drop
		if is_local_player():
			manage_money()


func spawn_money():
	var moneybag = preload("res://Props/MoneyBag/MoneyBag.tscn").instance()
	moneybag.translation = Vector3(translation.x, 4, translation.z)
	get_parent().get_parent().add_child(moneybag)
	

func _input(event):
	if event.is_action_pressed("play_siren") and is_local_player():
		if is_in_group("cops"):
			siren = !siren
			if not Network.local_player_id == 1:
				rpc_id(1, "toggle_siren", name, siren)
			else:
				toggle_siren(name, siren)
		else:
			rpc("play_horn", name)
		

sync func play_horn(id):
	if name == str(id):
		$Horn/Horn.play()

remote func toggle_siren(id, siren_state):
	players[id]["siren"] = siren_state


func check_siren_state():	
	if players[name]["siren"]:
		$Siren/ArrestArea.monitoring = true
		$Siren/ArrestArea/ArrestArea.show()
		if not $Siren/SirenSound.playing:
			$Siren/SirenSound.play()
			$Siren/SirenMesh/SpotLight.show()
			$Siren/SirenMesh/SpotLight2.show()
	else:
		$Siren/ArrestArea.monitoring = false
		$Siren/ArrestArea/ArrestArea.hide()
		$Siren/SirenSound.stop()
		$Siren/SirenMesh/SpotLight.hide()
		$Siren/SirenMesh/SpotLight2.hide()


func _on_ArrestArea_body_entered(body):
	body.criminal_detected = true


func _on_ArrestArea_body_exited(body):
	body.criminal_detected = false
	
	
func increment_arrest_value():
	if is_local_player():
		arrest_value += 1
		players[name]["arrest_value"] = arrest_value
	else:
		arrest_value = players[name]["arrest_value"]
	
	$PlayerBillboard/Viewport/TextureProgress.value = max_arrest_value - players[name]["arrest_value"]
	if players[name]["arrest_value"] >= max_arrest_value:
		player_got_arrested()
		
		
		

func player_got_arrested():
	var local_player_name = SaveGame.save_data["Player_name"]
	if not got_arrested:
		got_arrested = true
		if is_local_player():
			if not Network.local_player_id == 1:
				rpc_id(1, "announce_capture_criminal", local_player_name)
			else:
				announce_capture_criminal(local_player_name)

		add_to_group("captured")
		$DeleteTimer.start()



remote func announce_capture_criminal(player_name):
	rpc("remote_announce_capture_criminal", player_name)



sync func remote_announce_capture_criminal(player_name):
	get_tree().call_group("Announcement", "capture_criminal", player_name)
	



func _on_DeleteTimer_timeout():
	remove_from_group("robber")
	for i in get_children():
		if not ((i.name == "GUI") or (i.name == "DeleteTimer") or (i.name == "Tween")):
			i.hide()
	
	var robbers_num = count_robber()
	print(robbers_num)
	if robbers_num == 0:
		get_tree().call_group("EndGame", "victory", false)

	if is_local_player():
		$GUI/SpectateButton.visible = true
#		$Camera.current = false
		change_cam()
		rpc("check_change_cam", name)
		
	$CollisionShape.disabled = true


func change_cam():
	var player_list = check_active_players()
#	player_list.get_child(randi() % (player_list.get_children().size() - 2) + 1).get_node("Camera").current = true
	if player_spectate >= player_list.size():
		player_spectate = 0
	
	player_list[player_spectate].get_node("Camera").make_current()
	
#	$GUI/Button.text = "Spectate " + Network.players[player_list[player_spectate].name]["name"]
	player_spectate += 1
	

remote func check_change_cam(id):
	if get_parent().get_node(id).get_node("Camera").is_current():
		change_cam()


func check_active_players():
	var player_list = get_parent()
	var active_player = []
	for player in player_list.get_children():
		if not player.is_in_group("captured"):
			active_player.append(player)
	
	return active_player


func count_robber():
	var robbers_num = get_tree().get_nodes_in_group("robber").size()
	return robbers_num
	


func _on_Button_pressed():
#	print("Button pressed")
	if is_local_player():
		change_cam()
