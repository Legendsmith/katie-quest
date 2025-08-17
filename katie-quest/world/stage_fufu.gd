extends Node2D

@export var spawn_distance:float = 1900.0
@export var spawn_impulse_min:float = 2000.0
@export var spawn_impuse_max:float= 10000.0
@onready var level_area:Area2D = $LevelArea
@onready var start_position:Node2D = $StartMarker
@onready var level_camera:Camera2D = $Camera2D
@onready var player:Player = $Player
var emote_array:Array[Texture2D]
var emote_body:PackedScene = preload("res://entities/emote_body.tscn")

func _ready():
	level_area.body_exited.connect(handle_outside)
	VerySimpleTwitch.chat_message_received.connect(process_emotes)

func handle_outside(body):
	if body is Player:
		reset_player(body)
		return
	body.queue_free()

func reset_player(player_node:Player):
	player_node.global_position = start_position.global_position
	player_node.reset_physics_interpolation()


func process_emotes(chatter:VSTChatter):
	var words:Array[String] = chatter.message.split(" ",false)
	#for word in words:
	#	if word in :
	#		emote_array.append(VerySimpleTwitch.get_emote(word))


func spawn_emote(texture:Texture2D=null):
	var new_emote:RigidBody2D = emote_body.instantiate()
	if texture:
		new_emote.set_sprite(texture)
	var angle = randf_range(0.0,TAU)
	var spawn_position = Vector2(spawn_distance,0.0).rotated(angle)
	var spawn_impulse = Vector2.UP.rotated(angle) * randf_range(spawn_impulse_min,spawn_impuse_max)
	add_child(new_emote)
	new_emote.position = spawn_position
	new_emote.apply_central_force(spawn_impulse)

func _physics_process(delta):
	for texture in emote_array:
		spawn_emote(texture)
	emote_array.clear()


func _process(_delta):
	if Input.is_action_just_released(&"debug"):
		spawn_emote()
	level_camera.global_position = player.global_position
