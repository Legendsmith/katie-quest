extends Camera2D
const CAMERA_ZOOM_SPEED : Vector2 = Vector2(0.3, 0.3)
const CAMERA_ZOOM_DEFAULT : Vector2 = Vector2(1.0, 1.0)


func _process(_delta:float) -> void:
	if (Input.is_action_just_pressed(&"camera_zoom_in")):
		set_zoom(get_zoom() * (CAMERA_ZOOM_DEFAULT + CAMERA_ZOOM_SPEED))
		
	elif (Input.is_action_just_pressed(&"camera_zoom_out")):
		set_zoom(get_zoom() / (CAMERA_ZOOM_DEFAULT + CAMERA_ZOOM_SPEED))
		
	elif (Input.is_action_just_pressed(&"camera_zoom_reset")):
		set_zoom(CAMERA_ZOOM_DEFAULT)