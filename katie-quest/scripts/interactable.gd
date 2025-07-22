class_name Interactable
extends Area2D
signal interacted(player_actor:Node2D)
const VIEW_LABEL_TEXT_FUNCTION = "get_view_label_text"
@export var view_label_default:String = ""
@export var auto_interact:bool = true
@export var cursor_shape:Input.CursorShape = Input.CursorShape.CURSOR_POINTING_HAND
var _get_view_label_text:Callable = func(): return view_label_default
## Used if the parent or owner do not have view label functionality.

func _init():
	monitorable = true
	monitoring = false
	input_pickable = false
	collision_layer = 2
	collision_mask = 0
	if auto_interact: # for things like keys that automatically pickup.
		monitoring=true
		collision_mask = 1
		body_entered.connect(on_interaction)

func _ready():
	if get_parent().has_method(VIEW_LABEL_TEXT_FUNCTION):
		_get_view_label_text = Callable(get_parent(),VIEW_LABEL_TEXT_FUNCTION)
	elif owner.has_method(VIEW_LABEL_TEXT_FUNCTION):
		_get_view_label_text = Callable(owner,VIEW_LABEL_TEXT_FUNCTION)


func get_view_label_text():
	return _get_view_label_text.call()

func on_interaction(actor:Node2D) -> void:
	print_debug(actor.name, " interacted with ", name, "!")
	interacted.emit(actor)
	