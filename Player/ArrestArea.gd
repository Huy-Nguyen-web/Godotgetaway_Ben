extends CSGCylinder

export (NodePath) var follow_this_path = null
var player_position

func _ready():
	set_as_toplevel(true)
	
	
func _process(delta):
	player_position = get_node(follow_this_path).global_transform.origin
	transform.origin.x = player_position.x
	transform.origin.z = player_position.z
	transform.origin.y = 1.0
	

