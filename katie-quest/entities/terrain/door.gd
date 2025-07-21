extends Area2D
signal door_entered(door)
@export var locked = false
@export var open = false
@onready var door_sprite:Sprite2D =  $SpriteDoor
@onready var bolt_sprite:Sprite2D =  $SpriteBolt
@onready var lock_sprite:Sprite2D =  $SpriteLock
@onready var animation_player = $AnimationPlayer
@onready var door_check = $DoorCheck


func _ready():
	door_check.body_entered.connect(check_door)
	door_check.body_exited.connect(close_door)
	animation_player.play("closed")
	if locked:
		lock()

# func tilemap_data():
#	global_position

func unlock():
	animation_player.play("unlock")

func lock():
	animation_player.play("locked")

func check_door(body:Node2D):
	print_debug(body, "Entered door")
	if not body is Actor:
		return
	if locked:
		animation_player.play("locked")
	animation_player.play("open")
	

func close_door(_body:Node2D=null):
	if open:
		animation_player.play("close")
	

func enter_door():
	door_entered.emit(self)