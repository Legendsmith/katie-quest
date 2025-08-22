extends CharacterBody2D

@export var target: Node2D
@export var speed: float = 200.0
@export var accel:float = 100.0
@export var desired_range: float = 150.0

@onready var nav_agent = $NavigationAgent2D
@onready var speech_bubble = $SpeechBubble
@onready var stamina_restore_area = $StaminaRestoreArea
@onready var animations:AnimationPlayer = $AnimationPlayer

func _ready():
	add_to_group("kattens")
	
func chat_talk(chatter: VSTChatter):
	speech_bubble.set_text(chatter.message)
	stamina_restore_area.get_overlapping_bodies()[0].restore_stamina()

func _exit_tree() -> void:
	remove_from_group("kattens")

func _physics_process(_delta):
	if target == null:
		animations.play("idle")
		return
	nav_agent.target_position = target.global_position
	if nav_agent.is_navigation_finished():
		animations.play("idle")
		return
	var next_pos = nav_agent.get_next_path_position()
	var direction = global_position.direction_to(next_pos)
	velocity = velocity.move_toward(direction * speed,accel)
	look(direction)
	move_and_slide()


func look(vector:Vector2):
	var angle = vector.angle() / (PI/3)
	angle = wrapi(int(angle), 0, 4)
	$AnimationPlayer.play("walk_"+str(angle))