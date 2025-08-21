extends CharacterBody2D

@export var target: Node2D
@export var speed: float = 200.0
@export var desired_range: float = 150.0

@onready var nav_agent = $NavigationAgent2D
@onready var speech_bubble = $SpeechBubble

func _ready():
	add_to_group("kattens")
	
func chat_talk(chatter: VSTChatter):
	speech_bubble.set_text(chatter.message)

func _exit_tree() -> void:
	remove_from_group("kattens")
