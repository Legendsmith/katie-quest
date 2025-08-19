extends RigidBody2D
func set_sprite(sprite:Texture2D):
	$CollisionShape2D.shape.size = sprite.get_size() 
	$Sprite2D.texture = sprite

func _draw():
	draw_rect(Rect2(-$CollisionShape2D.shape.size/2,$CollisionShape2D.shape.size),Color.GRAY)