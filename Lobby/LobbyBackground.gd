extends Spatial

var robber_paint
var cops_paint

var default_color


func _ready():
	make_material()
	apply_defaults()
	
func make_material():
	var new_robbers_paint = load("res://Lobby/DefaultCarPaint.tres")
	var new_cops_paint = load("res://Lobby/DefaultCopsPaint.tres")
	$Pivot/Criminal1.set_surface_material(0, new_robbers_paint)
	$Pivot/Criminal2.set_surface_material(0, new_robbers_paint)
	$Pivot/Cop1.set_surface_material(0, new_cops_paint)
	$Pivot/Cop2.set_surface_material(0, new_cops_paint)
	
	robber_paint = $Pivot/Criminal1.get_surface_material(0)
	cops_paint = $Pivot/Cop1.get_surface_material(0)


func pivot():
	$AudioStreamPlayer.play()
	var rot = $Pivot.rotation_degrees.y
	$Tween.interpolate_property($Pivot, "rotation_degrees",
			Vector3(0, rot, 0), Vector3(0, rot + 180, 0), 1, 
			Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	

func apply_defaults():
	apply_cops_defaults()
	apply_robber_defaults()


func apply_robber_defaults():
	robber_paint.metallic_specular = 0.5
	robber_paint.albedo_color = Color(0.47, 0.1, 0)
	robber_paint.roughness = 0.35
	Network.robber_paint = robber_paint.albedo_color

	
func apply_cops_defaults():
	cops_paint.metallic_specular = 0.5
	cops_paint.albedo_color = Color(0, 0.02, 0.23)
	cops_paint.roughness = 0.35
	Network.cops_paint = cops_paint.albedo_color
	
func new_cops_color(color):
	cops_paint.albedo_color = color
	Network.cops_paint = color
	
func new_robber_color(color):
	robber_paint.albedo_color = color
	Network.robber_paint = color

