extends Particles

const MAX_LIFETIME = 2


func _ready():
	emitting = SaveGame.save_data["particles"]


func update_particles(speed):
	lifetime = MAX_LIFETIME / (speed + 0.01)


func manage_particles(value):
	emitting = value
	SaveGame.save_data["particles"] = value
	SaveGame.save_game()
