extends Node

var save_data: SaveData
var last_scene_path: String = ""

func _ready():
	save_data = SaveData.load_from_file()
	get_tree().connect("tree_changed", _on_scene_changed)

func _on_scene_changed():
	if not get_tree():
		return

	await get_tree().process_frame
	check_and_auto_save()

func check_and_auto_save():
	if not get_tree() or not get_tree().current_scene:
		return

	var scene_path = get_tree().current_scene.scene_file_path

	if scene_path == last_scene_path:
		return

	last_scene_path = scene_path
	var scene_name = scene_path.get_file().get_basename()
	
	var game_scenes = [ "demo_level" ]

	for game_scene in game_scenes:
		if scene_name == game_scene:
			print("Entered game scene, auto-saving...")
			save_data.current_scene = scene_path
			sync_player_data()
			save_data.save_to_file()
			break

func sync_player_data():
	var player = get_tree().get_first_node_in_group("player") as Player
	if player:
		save_data.inventory = player.items

func save_current_scene():
	if not get_tree() or not get_tree().current_scene:
		print("No current scene to save")
		return

	save_data.current_scene = get_tree().current_scene.scene_file_path
	sync_player_data()

	if save_data.save_to_file():
		print("Scene saved: ", save_data.current_scene.get_file())

func load_saved_scene():
	if not get_tree() or save_data.current_scene == "":
		return

	print("Loading scene: ", save_data.current_scene)
	get_tree().change_scene_to_file(save_data.current_scene)

	await get_tree().process_frame
	await get_tree().process_frame

	restore_player_data()

func restore_player_data():
	if not get_tree():
		return

	var player = get_tree().get_first_node_in_group("player") as Player

	if player and save_data.inventory:
		player.items = save_data.inventory
