extends Area2D
signal door_entered(door)
@export var locked:bool = false
@export var open:bool = false
@onready var door_sprite:Sprite2D =  $SpriteDoor
@onready var bolt_sprite:Sprite2D =  $SpriteBolt
@onready var lock_sprite:Sprite2D =  $SpriteLock
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var door_check = $DoorCheck


func _ready():
	print_debug("Door locked: ", locked)
	body_entered.connect(enter_door)
	door_check.body_entered.connect(check_door)
	door_check.body_exited.connect(close_door)
	door_check.interacted.connect(check_door)
	animation_player.play("closed")
	door_check.enable_auto_interact()
	if locked:
		animation_player.play("locked")

func unlock():
	#print_debug("Door unlocked")
	animation_player.play("unlock")
	await animation_player.animation_finished
	#locked = false
	if door_check.has_overlapping_bodies():
		animation_player.play("open")

func lock():
	animation_player.play("locked")
	#locked = true

func check_door(body:Node2D) -> void:
	#print_debug(body, " Checked door")
	if not body is Player:
		return
	var player:Player = body
	if not locked:
		open = true
		animation_player.play("open")
		return
	if player.items.keys > 0:
		player.items.keys -=1
		unlock()
	
	
func get_view_label_text():
	if locked:
		return "Locked"
	return "Door"

func close_door(_body:Node2D=null):
	if not locked:
		animation_player.play("close")
		open = false
	

func enter_door(body:Node2D):
	#print_debug(body, " Entered Door")
	door_entered.emit(self)
