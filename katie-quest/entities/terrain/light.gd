extends PointLight2D
func _ready():
	Global.light_level.connect(_on_light_level)

func _on_light_level(new_energy:float):
	energy=new_energy