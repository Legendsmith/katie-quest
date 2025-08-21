extends RigidBody2D

@export var target: Node2D
@export var speed: float = 200.0
@export var desired_range: float = 150.0

@onready var nav_agent = $NavigationAgent2D

func _ready():
	VerySimpleTwitch.chat_message_received.connect(chat_talk)

func chat_talk(chatter:VSTChatter):
	speech_bubble.set_text(chatter.message)

func _physics_process(_delta):
  if target == null:
    return

  nav_agent.target_position = target.global_position

  if nav_agent.is_navigation_finished():
    return

  var next_pos = nav_agent.get_next_path_position()
  var direction = (next_pos - global_position).normalized()

  linear_velocity = direction * speed
