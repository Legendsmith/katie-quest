extends CharacterBody2D

@export var target: Node2D
@export var speed: float = 200.0
@export var desired_range: float = 150.0

@onready var nav_agent = $NavigationAgent2D
@onready var speech_bubble = $SpeechBubble

var message_count = 0
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

	messages_needed = randi_range(5, 6)

func chat_talk(chatter: VSTChatter):
	if not chatter.tags.display_name in DataManager.npc_channel_list:
		if is_on_cooldown:
			return

		message_count += 1

		if message_count >= messages_needed:
			speech_bubble.set_text(chatter.message)
			message_count = 0
			messages_needed = randi_range(5, 6)
			is_on_cooldown = true
			cooldown_timer.start()

func _physics_process(_delta):
	if target == null:
		return

	nav_agent.target_position = target.global_position

	if nav_agent.is_navigation_finished():
		return

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_cooldown_finished():
	is_on_cooldown = false
