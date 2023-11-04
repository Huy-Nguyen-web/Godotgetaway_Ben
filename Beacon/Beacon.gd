extends Area

var size 
var player
var wait

func _ready():
	wait = $Timer.wait_time
	if Network.is_cop:
		hide()
		

func  _physics_process(delta):
	if not $Timer.is_stopped():
		size = $Timer.time_left/wait
		$CSGCylinder.scale.x = size
		$CSGCylinder.scale.z = size
		# Test if instead change the scale, change the radius of the cylinder
#		$CSGCylinder.radius = size

	else:
		$CSGCylinder.scale.x = 1
		$CSGCylinder.scale.z = 1
		


func _on_Spatial_body_entered(body):
	player = body
	$Timer.start()
	$HideTimer.start()
	show()
	get_tree().call_group("Announcement", "announce_crime", translation)


func _on_Spatial_body_exited(body):
	$Timer.stop()
	player = null
	


func _on_Timer_timeout():
	if not name == "Goal":
		player.beacon_emptied()
		queue_free()
		print("trigger")


func _on_HideTimer_timeout():
	if Network.is_cop:
		hide()
