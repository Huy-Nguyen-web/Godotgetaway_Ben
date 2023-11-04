extends Spatial

var destination = Vector3.ZERO

func _process(delta):
	look_at(destination, Vector3(0, 1, 0))


func new_destination(new_destination):
	destination = new_destination
	play_animation()
	
func play_animation():
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	
	$AnimationPlayer.play("Arrow")
