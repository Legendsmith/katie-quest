extends Node2D

@onready var world_bounds:StaticBody2D = $WorldBounds
@onready var level_camera:Camera2D = $Camera2D
@onready var player:Player = $Player

func _ready():
	# Sets the Limits of the camera based on the world bounds node. This must have its children in order of left, Top Right, and Bottom.
	level_camera.limit_left = int($WorldBounds.get_child(0).position.x)
	level_camera.limit_top = int($WorldBounds.get_child(1).position.y)
	level_camera.limit_right = int($WorldBounds.get_child(2).position.x)
	level_camera.limit_bottom = int($WorldBounds.get_child(3).position.y)
	Global.do_timeline("res://shared/test_timeline.dtl")

func _process(_delta):
	level_camera.global_position = player.global_position