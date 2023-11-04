extends Popup

onready var drive_forward = $CenterContainer/VBoxContainer/CenterContainer/GridContainer/DriveForwardButton
onready var drive_backward = $CenterContainer/VBoxContainer/CenterContainer/GridContainer/DriveBackwardButton
onready var steer_right = $CenterContainer/VBoxContainer/CenterContainer/GridContainer/SteerRightButton
onready var steer_left = $CenterContainer/VBoxContainer/CenterContainer/GridContainer/SteerLeftButton
onready var brake = $CenterContainer/VBoxContainer/CenterContainer/GridContainer/BrakeButton
onready var siren = $CenterContainer/VBoxContainer/CenterContainer/GridContainer/SirenButton

var keybinds
var waiting_input = false
var key_pressed
var key
var value


func _ready():
	keybinds = Global.keybinds
	for key in keybinds.keys():
		var button_value
		button_value = keybinds[key]
		match key:
			"forward":
				drive_forward.text = OS.get_scancode_string(button_value)
			"back":
				drive_backward.text = OS.get_scancode_string(button_value)
			"steer_right":
				steer_right.text = OS.get_scancode_string(button_value)
			"steer_left":
				steer_left.text = OS.get_scancode_string(button_value)
			"brake":
				brake.text = OS.get_scancode_string(button_value)
			"play_siren":
				siren.text = OS.get_scancode_string(button_value)
				


func _input(event):
	if waiting_input:
		if event is InputEventKey:
			value = event.physical_scancode
			match key_pressed:
				"forward":
					drive_forward.text = OS.get_scancode_string(value)
				"back":
					drive_backward.text = OS.get_scancode_string(value)
				"steer_right":
					steer_right.text = OS.get_scancode_string(value)
				"steer_left":
					steer_left.text = OS.get_scancode_string(value)
				"brake":
					brake.text = OS.get_scancode_string(value)
				"play_siren":
					siren.text = OS.get_scancode_string(value)
					
			change_bind(key_pressed, value)
			
			
			waiting_input = false
			$Popup.visible = false
		
		elif event is InputEventMouseButton:
			waiting_input = false
			$Popup.visible = false
		


func _on_DoneButton_pressed():
	hide()


func _on_DriveForwardButton_pressed():
	key_pressed = "forward"
	waiting_input = true
	$Popup.visible = true


func _on_DriveBackwardButton_pressed():
	key_pressed = "back"
	waiting_input = true
	$Popup.visible = true


func _on_SteerRightButton_pressed():
	key_pressed = "steer_right"
	waiting_input = true
	$Popup.visible = true


func _on_SteerLeftButton_pressed():
	key_pressed = "steer_left"
	waiting_input = true
	$Popup.visible = true


func _on_BrakeButton_pressed():
	key_pressed = "brake"
	waiting_input = true
	$Popup.visible = true


func _on_SirenButton_pressed():
	key_pressed = "play_siren"
	waiting_input = true
	$Popup.visible = true


func change_bind(key, button_value):
	keybinds[key] = button_value
	Global.keybinds = keybinds
	Global.set_game_binds()
	Global.write_config()
