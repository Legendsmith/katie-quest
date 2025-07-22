extends Area2D
@onready var interact_ray:RayCast2D = $InteractionRay
func _init():
	set_collision_mask_value(1,false)
	set_collision_mask_value(2,true)

# Detects Interactable Areas and

func _ready():
	#area_entered.connect(_on_area_entered)
	#area_exited.connect(_on_area_exited)
	collision_layer = 2
	collision_mask = 2
	interact_ray.enabled = false
	interact_ray.collision_mask = 3


func _process(_delta):
	Global.view_label_string = ""
	interact_ray.enabled = has_overlapping_areas()
	if not has_overlapping_areas():
		Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)
		return
	interact_ray.target_position = get_local_mouse_position()
	if interact_ray.get_collider() is Interactable:
		var target = interact_ray.get_collider()
		Input.set_default_cursor_shape(target.cursor_shape)
		Global.view_label_string = target.call(Interactable.VIEW_LABEL_TEXT_FUNCTION)
	

func _input(event):
	if event.is_action_released(&"primary_button") and interact_ray.get_collider() is Interactable:
		var interaction_target = interact_ray.get_collider()
		interaction_target.on_interaction(owner)




#func _on_area_entered(area:Area2D):
#	if area is Interactable:
#		area.input_pickable = true
#
#
#func _on_area_exited(area:Area2D):
#	if area is Interactable:
#		area.input_pickable = false
	
