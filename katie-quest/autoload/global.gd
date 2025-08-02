extends Node
signal light_level(energy:float)
const TILE_SIZE:Vector2i = Vector2i(64,64)

var view_label_string:String = ""


func grid_snap(tile_layer, node:Node2D):
	var snapped_pos:Vector2 = tile_layer.to_global(tile_layer.map_to_local(tile_layer.local_to_map(tile_layer.to_local(node.global_position))))
	return snapped_pos

func set_light_level(new_energy:float):
	light_level.emit(new_energy)