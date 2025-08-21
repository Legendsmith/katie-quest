extends CharacterBody2D

@export var target: Node2D
@export var speed: float = 200.0
@export var desired_range: float = 150.0

@onready var nav_agent = $NavigationAgent2D
@onready var speech_bubble = $SpeechBubble

static var global_message_count = 0

var messages_needed = 5
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
	if not chatter.tags.display_name in DataManager.npc_channel_list:
		if is_on_cooldown:
			return

		global_message_count += 1

		if global_message_count >= messages_needed:
			speech_bubble.set_text(chatter.message)
			global_message_count = 0
			is_on_cooldown = true
			cooldown_timer.start()

func _on_cooldown_finished():
	is_on_cooldown = false
