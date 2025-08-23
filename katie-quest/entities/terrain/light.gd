extends PointLight2D
func _ready():
	Global.light_level.connect(_on_light_level)

func _on_light_level(new_energy:float, fade_time=0.0):
	if fade_time:
		var tween = Tween.new()
		tween.tween_property(self,^"energy",new_energy,fade_time)
		return
	energy=new_energy