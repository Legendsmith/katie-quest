class_name ChatManager
extends Node
const BASE_COOLDOWN:float = 3.5
var cooldown_timer:Timer
var is_cooldown:bool = false
func _ready():
	Global.speech_manager = self
	VerySimpleTwitch.chat_message_received.connect(on_chat)
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot=true
	cooldown_timer.wait_time=BASE_COOLDOWN


func on_chat(chatter: VSTChatter):
	# If we're on cooldown or this is a named character, return.
	if chatter.tags.display_name in DataManager.npc_channel_list or is_cooldown:
		return
	var katten_count = get_tree().get_node_count_in_group("kattens")
	if katten_count == 0: #exit if there's no Kattens
		return
	var kattens:Array[Node] = get_tree().get_nodes_in_group("kattens")
	# Pick a random katten and make him talk.
	var selected_katten:CharacterBody2D = kattens.pick_random()
	selected_katten.chat_talk(chatter)
	 # The more kattens there are the lower the cooldown becomes
	cooldown_timer= BASE_COOLDOWN * max(0,pow(0.75,float(katten_count-1)))
	is_cooldown = true
	cooldown_timer.start()

func on_cooldown_finished():
	is_cooldown= false