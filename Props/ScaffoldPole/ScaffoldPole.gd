extends RigidBody

var pipe_sound = [
	preload("res://SFX/Pipes/Pipe1.ogg"),
	preload("res://SFX/Pipes/Pipe2.ogg"),
	preload("res://SFX/Pipes/Pipe3.ogg"),
	preload("res://SFX/Pipes/Pipe4.ogg"),
]

func _ready():
	randomize()


func _on_ScaffoldPole_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if not sleeping and not $AudioStreamPlayer3D.playing:
		pick_sound()
		$AudioStreamPlayer3D.play()


func pick_sound():
	$AudioStreamPlayer3D.stream = pipe_sound[randi()%pipe_sound.size() - 1]
