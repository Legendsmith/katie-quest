extends Interactable
@export var character_name = ""
@export var timelines:Array[DialogicTimeline]

@onready var speech_bubble:Node2D = $SpeechBubble
func _ready():
	VerySimpleTwitch.chat_message_received.connect(chat_talk)

func chat_talk(chatter:VSTChatter):
	if chatter.tags.display_name == character_name:
		speech_bubble.set_text(chatter.message)
		

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