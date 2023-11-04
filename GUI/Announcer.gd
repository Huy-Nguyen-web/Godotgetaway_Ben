extends CenterContainer

func money_stashed(player, money):
	rpc("announce_money", player, money)
	
sync func announce_money(player, money):
	$Label.text = "$" + str(money) + " has been stashed by " + player
	announce()

sync func announce_crime(location):
	var x = stepify(location.x, 1)
	var z = stepify(location.z, 1)
	$Label.text = "Crime in progress at " + str(x) + " - " + str(z)
#	$AnimationPlayer.play("Announcement")
	announce()
	get_tree().call_group("Arrow", "new_destination", location)


func announce():
	$AnimationPlayer.stop(true)
	$AnimationPlayer.play("Announcement")


func capture_criminal(player):
	rpc("capture_announce", player)


sync func capture_announce(player):
	$Label.text = player + " has been captured"
	announce()
	


func victory(criminal_win):
	# Announce base on the criminal win condition
	rpc("announce_victory", criminal_win)
		

sync func announce_victory(criminal_win):
	if criminal_win:
		$Label.text = "Criminal Team Win!"
	else:
		$Label.text = "Cops Team Win!"
		
	announce()
