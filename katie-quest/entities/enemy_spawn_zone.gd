class_name EnemySpawnZone
extends CollisionShape2D
#@export var shape:Shape2D = RectangleShape2D.new()
@export var enemies:Dictionary[PackedScene,int]

func _ready():
	owner.ready.connect(spawn)

func get_spawn_pos()-> Vector2:
			return Vector2(
			randf_range(
			shape.get_rect().position.x,shape.get_rect().end.x),
			randf_range(shape.get_rect().position.y,shape.get_rect().end.y)
		)
	
func spawn():
	for enemy_scene:PackedScene in enemies.keys():
		var count = enemies[enemy_scene]
		for i in count:
			var pos:Vector2 = get_spawn_pos()
			var new_enemy = enemy_scene.instantiate()
			owner.add_child(new_enemy)
			new_enemy.global_position = to_global(pos)
			new_enemy.reset_physics_interpolation()
	queue_free()