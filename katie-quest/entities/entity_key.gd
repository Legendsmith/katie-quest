class_name EntityKey
extends Interactable
var pickup_sound = preload("res://audio/ring_inventory.wav")

func _init():
	auto_interact=true
	view_label_default = "Key"
	super()

func on_interaction(actor:Node2D) -> void:
	super(actor)
	actor.play_sound(pickup_sound)
	actor.items.keys+=1
	queue_free()

	
	
