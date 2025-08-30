extends RigidBody2D
@export var attack_force:float = 1000.0

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