extends Interactable
@export var character_name = ""
@export var timelines:Array[DialogicTimeline]


func _ready():
	pass


func on_interaction(actor:Node2D) -> void:
	if not  actor is Player:
		return
	print_debug(actor.name, " interacted with ", name, "!")
	interacted.emit(actor)
	dialog(actor)


func get_view_label_text():
	return character_name


func dialog(player:Node2D):
	print_debug(player)
	if is_ancestor_of(player): 
		return
	Global.do_timeline(timelines[0])
