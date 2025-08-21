class_name Player
extends CharacterBody2D

@export var move_speed:float = 5000.0
@export var items:Inventory

@export var max_speed: float = 8000.0
@export var acceleration: float = 3000.0
@export var deceleration: float = 5000.0

# Physics parameters
@export var player_mass: float = 70.0  # Player's mass in kg
@export var push_force_multiplier: float = 8.0  # Base force multiplier for pushing
@export var knockback_threshold: float = 50.0  # Minimum relative velocity for knockback
@export var physics_material_override:PhysicsMaterial


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

	handle_rigidbody_interactions()
	handle_wall_bouncing()

func handle_rigidbody_interactions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody2D:
			var rigid_body = collider as RigidBody2D
			var collision_point = collision.get_position()
			var collision_normal = collision.get_normal()
			
			# Get physics material properties
			var physics_material:PhysicsMaterial = rigid_body.physics_material_override
			var friction = 1.0
			var bounce = 0.0
			
			if physics_material:
				friction = physics_material.friction
				bounce = physics_material.bounce
			
			# Calculate push direction (from player to rigidbody)
			var push_direction = -collision_normal
			
			# Get masses
			var rigidbody_mass = rigid_body.mass
			var mass_ratio = player_mass / (player_mass + rigidbody_mass)
			
			# Calculate base push force based on player's momentum and mass
			var player_momentum = velocity.length() * player_mass
			var base_push_force = player_momentum * push_force_multiplier / rigidbody_mass
			
			# Apply friction from physics material (higher friction = easier to push)
			var adjusted_push_force = base_push_force * (1.0 + friction)
			
			# Get the contact point relative to the rigidbody
			var contact_point = collision_point - rigid_body.global_position
			
			# Apply impulse to push the rigidbody
			var push_impulse = push_direction * adjusted_push_force * get_physics_process_delta_time()
			rigid_body.apply_impulse(push_impulse, contact_point)
			
			# Calculate resistance based on mass difference and friction
			var resistance_factor = (1.0 - mass_ratio) * (2.0 - friction)  # Less friction = more resistance
			var velocity_reduction = velocity.length() * resistance_factor * 0.3
			
			# Apply resistance to player movement
			if velocity.length() > 0:
				var resistance_force = velocity.normalized() * -velocity_reduction
				velocity += resistance_force * get_physics_process_delta_time()
			
			# Handle being knocked back by moving rigidbodies
			var rigidbody_velocity = rigid_body.linear_velocity
			var relative_velocity = rigidbody_velocity - velocity
			var impact_velocity = relative_velocity.dot(-collision_normal)
			
			if impact_velocity > knockback_threshold:
				# Calculate knockback based on conservation of momentum
				var combined_mass = player_mass + rigidbody_mass
				var momentum_transfer = (2.0 * rigidbody_mass / combined_mass) * impact_velocity
				
				# Apply physics material bounce
				var total_bounce = bounce
				if physics_material and physics_material.absorbent:
					total_bounce = min(0,-bounce)
				
				# Apply knockback impulse
				var knockback_impulse = collision_normal * momentum_transfer * (1.0 + total_bounce)
				velocity += knockback_impulse * 0.01  # Scale down for gameplay feel

func handle_wall_bouncing():
	# Check if we collided with something that's NOT a RigidBody2D
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Only bounce off walls/static bodies, not RigidBody2D objects
			if not collider is RigidBody2D:
				var collision_normal = collision.get_normal()
				
				# Check for physics material on static bodies
				var bounce_coefficient = 0.6  # Default bounce
				if collider.has_method("get_physics_material_override"):
					var p_material = collider.get_physics_material_override()
					if p_material:
						bounce_coefficient = p_material.bounce
				
				# Calculate bounce velocity using physics material
				var bounce_velocity = velocity.bounce(collision_normal)
				velocity = bounce_velocity * bounce_coefficient
