extends Interactable
@export var character_name = ""
@export var timelines: Array[DialogicTimeline]
var dialog_idx = 0

@onready var speech_bubble: Node2D = $SpeechBubble

var is_on_cooldown = false
var cooldown_timer: Timer

func _ready():
	VerySimpleTwitch.chat_message_received.connect(chat_talk)

	cooldown_timer = Timer.new()

	add_child(cooldown_timer)

	cooldown_timer.wait_time = 5.0
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_finished)

func chat_talk(chatter: VSTChatter):
	if chatter.tags.display_name == character_name:
		if is_on_cooldown:
			return

		speech_bubble.set_text(chatter.message)
		is_on_cooldown = true
		cooldown_timer.start()

func on_interaction(actor: Node2D) -> void:
	if not actor is Player:
		return

	print_debug(actor.name, " interacted with ", name, "!")
	interacted.emit(actor)
	dialog(actor)

func get_view_label_text():
	return character_name

func dialog(player: Node2D):
	print_debug(player)
	if is_ancestor_of(player):
		return

	if len(timelines) > 0:
		Global.do_timeline(timelines[0])
		await Dialogic.timeline_ended
		dialog_idx = min(dialog_idx+1,len(timelines)-1)

func _on_cooldown_finished():
	is_on_cooldown = false
