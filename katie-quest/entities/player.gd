class_name Player
extends CharacterBody2D

@export var move_speed:float = 8000.0
@export var sprint_bonus:float = 1.0
@export var items:Inventory

@onready var audio_player:AudioStreamPlayer = $AudioStreamPlayer
var move_target:Vector2
var facing:Vector2 = Vector2.RIGHT
var moving = false

func _ready():
	add_to_group("player")

func play_sound(sound:AudioStream):
	audio_player.stream=sound
	audio_player.play()

func _physics_process(delta):
	if moving:
		var speed = move_speed * (1 + (sprint_bonus * Input.get_action_strength(&"sprint")))
		velocity = global_position.direction_to(move_target) * speed * delta
		move_and_slide()

func _process(_delta):
	movement()


func movement():
	var input_dir:Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input_dir.is_zero_approx(): # early exit
		moving = false
		return
	var angle = input_dir.angle() / (PI/2)
	angle = wrapi(int(angle), 0, 4)
	$AnimationPlayer.play("look_"+str(angle))
	move_target = global_position + (input_dir * Vector2(Global.TILE_SIZE))
	moving = true
