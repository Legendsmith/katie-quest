extends RigidBody2D

@export var target: Node2D
@onready var nav_agent = $NavigationAgent2D
@onready var speech_bubble = $SpeechBubble
var is_moving: bool = false

@export var move_force: float = 500.0
@export var max_speed: float = 400.0
@export var arrival_distance: float = 10.0
@export var damping_factor: float = 0.8


func _ready():
	VerySimpleTwitch.chat_message_received.connect(chat_talk)
	gravity_scale = 0.0  # Disable gravity for top-down movement
	linear_damp = 2.0    # Add some base damping
	angular_damp = 3.0   # Prevent unwanted rotation

func chat_talk(chatter:VSTChatter):
	speech_bubble.set_text(chatter.message)

func _physics_process(delta):
	if target == null:
		apply_braking()
		return

	nav_agent.target_position = target.global_position
	if nav_agent.is_navigation_finished():
		apply_braking()
		return
	var next_pos = nav_agent.get_next_path_position()
	move_towards_target(next_pos, delta)

func move_towards_target(target_position:Vector2, delta:float):
	var distance_to_target = global_position.distance_to(target_position)
	var direction = (target_position - global_position).normalized()
	var desired_velocity = direction * max_speed
	var arrival_radius = nav_agent.target_desired_distance *3
	if distance_to_target < arrival_radius:
		var arrival_factor = distance_to_target / arrival_radius
		desired_velocity *= arrival_factor
	var velocity_difference = desired_velocity - linear_velocity
	var steering_force = velocity_difference * move_force * delta
	apply_central_force(steering_force)
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
func apply_braking():
	# Apply stronger damping when not actively moving
	linear_velocity.lerp(Vector2.ZERO,damping_factor)
