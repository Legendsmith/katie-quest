class_name Player
extends CharacterBody2D

@export var move_speed:float = 5000.0
@export var items:Inventory

@export var max_speed: float = 10000.0
@export var acceleration: float = 3000.0
@export var deceleration: float = 5000.0

@onready var audio_player:AudioStreamPlayer = $AudioStreamPlayer
var move_target:Vector2
var facing:Vector2 = Vector2.RIGHT
var moving = false

func _ready():
	add_to_group("player")

func play_sound(sound:AudioStream, bus:StringName=&"Effects"):
	audio_player.bus=bus
	audio_player.stream=sound
	audio_player.play()

func _physics_process(delta):
	if Input.is_action_pressed(&"sprint"):
		var target_velocity = global_position.direction_to(move_target) * max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	elif moving:
		var speed = move_speed
		velocity = global_position.direction_to(move_target) * speed * delta
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	move_and_slide()
	handle_wall_bouncing()


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

func handle_wall_bouncing():
	# Check if we collided with something
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collision_normal = collision.get_normal()
			
			# Calculate bounce velocity
			# Reflect the velocity off the surface normal
			var bounce_velocity = velocity.bounce(collision_normal)
			velocity = bounce_velocity * 0.4  