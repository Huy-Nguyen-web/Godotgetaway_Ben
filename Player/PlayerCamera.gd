extends Camera

const MAX_CAMERA_ANGLE = 90

var EW_line # East-West line
var NS_line # North-South line

export (NodePath) var follow_this_path = null
export var target_distance = 12.0
export var target_height = 2.0

var follow_this = null
var last_lookat : Vector3


func _ready():
	make_neighbourhoods()
	set_as_toplevel(true)
	environment = load(Network.environment)
	follow_this = get_node(follow_this_path)
	last_lookat = follow_this.global_transform.origin
	check_saved_setting()
	
func _physics_process(delta):
#	if EW_line != null:
#		manage_bus_levels()
		
	var delta_v = global_transform.origin - follow_this.global_transform.origin
	var target_pos = global_transform.origin
	
	delta_v.y = 0
	
	if delta_v.length() > target_distance:
		delta_v = delta_v.normalized() * target_distance
		delta_v.y = target_height
		target_pos = follow_this.global_transform.origin + delta_v
	else:
		target_pos.y = follow_this.global_transform.origin.y + target_height
		
	global_transform.origin = global_transform.origin.linear_interpolate(target_pos, 1)
	last_lookat = last_lookat.linear_interpolate(follow_this.global_transform.origin, 1)
	
	look_at(last_lookat, Vector3(0, 1, 0))
	

func make_neighbourhoods():
	EW_line = (Network.city_size.x * 20) / 2
	NS_line = (Network.city_size.y * 20) / 2


func manage_bus_levels():
	var n1 = global_transform.origin.x < EW_line and global_transform.origin.z < NS_line
	var n2 = global_transform.origin.x < EW_line and global_transform.origin.z > NS_line
	var n3 = global_transform.origin.x > EW_line and global_transform.origin.z < NS_line
	var n4 = global_transform.origin.x > EW_line and global_transform.origin.z > NS_line
	var neighbourhood = {3 : n1, 4 : n2, 5 : n3, 6 : n4}
	
	for i in range(3, 7):
		AudioServer.set_bus_mute(i, !neighbourhood[i])
		
		
func update_speed(speed):
	fov = 70 + speed
	fov = min(fov, MAX_CAMERA_ANGLE)
	
	
func check_saved_setting():
	if SaveGame.save_data["far_cam"]:
		far = 600
	else:
		far = 150
		
	environment.ss_reflections_enabled = SaveGame.save_data["reflection"]
	environment.ssao_enabled = SaveGame.save_data["reflection"]
	get_tree().call_group("ManageShadow", "set_shadow", SaveGame.save_data["shadow"])
	

func reflections(value):
	environment.ss_reflections_enabled = value
	environment.ssao_enabled = value
	SaveGame.save_data["reflection"] = value
	SaveGame.save_game()


func shadow(value):
	get_tree().call_group("ManageShadow", "set_shadow", value)
	SaveGame.save_data["shadow"] = value
	SaveGame.save_game()
	
	
func far_cam(value):
	if value:
		far = 600
	else:
		far = 150
	
	SaveGame.save_data["far_cam"] = value
	SaveGame.save_game()
