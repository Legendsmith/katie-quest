class_name Actor
extends CharacterBody2D

@export var move_speed:float = 8000.0
@export var sprint_bonus:float = 1.0
@export var tile_layer:TileMapLayer

var tile_size:Vector2i
var move_target:Vector2
var moving = false

func _ready():
	tile_size = tile_layer.tile_set.tile_size

func _physics_process(delta):
	if moving:
		var speed = move_speed * (1 + (sprint_bonus * Input.get_action_strength(&"sprint")))
		velocity = global_position.direction_to(move_target) * speed * delta
		move_and_slide()

func _process(delta):
	var new_input:Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	# Movement. Anything else should be above this
	if new_input.is_zero_approx(): # early exit
		moving = false
		return
	move_target = global_position + (new_input * Vector2(tile_size))
	moving = true

func grid_snap():
	var snapped_pos:Vector2 = tile_layer.to_global(tile_layer.map_to_local(tile_layer.local_to_map(tile_layer.to_local(global_position))))
	if is_zero_approx(snapped_pos.distance_to(global_position)):
		return
	# Todo: make it grid snap?
