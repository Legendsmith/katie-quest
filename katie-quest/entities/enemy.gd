extends CharacterPhysics
@export var attack_force:float = 1000.0
@export var drift_force:float = 150.0
@onready var attack_area:Area2D = $AttackArea
@onready var chase_area:Area2D = $ChaseArea
@export var drift_speed:float = 200.0
func _ready():
	drift()
	attack_area.body_entered.connect(attack)
	chase_area.body_entered.connect(chase)
	chase_area.body_exited.connect(unchase)
	body_entered.connect(attack)
	

func drift():
	apply_central_impulse(Vector2.RIGHT.rotated(randf_range(0,TAU))* randf_range(drift_force/3,drift_force))


func chase(body):
	target=body
func unchase(body):
	if body == target:
		target=null


func attack(body):
	if not body is Player:
		return
	var player:Player = body
	$AnimationPlayer.play("attack")
	var vec = (player.velocity * 0.2) + global_position.direction_to(player.position).normalized() * (attack_force/player.stamina)
	player.set_physics_process(false)
	await get_tree().create_timer(0.3).timeout
	player.set_physics_process(true)
	player.stun()
	player.velocity = vec
	player.stamina *=0.9
	unchase(body)
	drift()



func apply_braking():
	# Apply stronger damping when not actively moving
	linear_velocity.lerp(linear_velocity.limit_length(drift_speed),damping_factor)
