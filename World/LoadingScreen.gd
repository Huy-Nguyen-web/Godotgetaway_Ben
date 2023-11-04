extends TextureRect


func update_loading_screen(players_num, max_players):
	$CenterContainer/Loading.value = players_num
	$CenterContainer/Loading.max_value = max_players
	
func start_game():
	$CenterContainer/Label.text = "Ready!"
	yield(get_tree().create_timer(1), "timeout")
	$AnimationPlayer.play("FadeOut")
	yield(get_tree().create_timer(.5),"timeout")
	queue_free()
