extends Node
signal light_level(energy:float)
const TILE_SIZE:Vector2i = Vector2i(128,128)
const PLAYER_GROUP = "player"
var view_label_string:String = ""


func grid_snap(tile_layer, node:Node2D):
	var snapped_pos:Vector2 = tile_layer.to_global(tile_layer.map_to_local(tile_layer.local_to_map(tile_layer.to_local(node.global_position))))
	return snapped_pos

func set_light_level(new_energy:float):
	light_level.emit(new_energy)

func do_timeline(timeline):
	get_tree().call_group("player","set_process",false)
	Dialogic.start(timeline)
	await Dialogic.timeline_ended
	get_tree().call_group("player","set_process",true)
