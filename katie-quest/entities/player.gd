class_name Player
extends CharacterBody2D

@export var move_speed:float = 8000.0
@export var sprint_bonus:float = 1.0
@export var items:Inventory

@onready var audio_player:AudioStreamPlayer = $AudioStreamPlayer

var move_target:Vector2
var moving = false

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
	var new_input:Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if new_input.is_zero_approx(): # early exit
		moving = false
		return
	move_target = global_position + (new_input * Vector2(Global.TILE_SIZE))
	moving = true
