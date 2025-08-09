extends Node

var channel_name: String = "melkornwah"

func _ready():
	VerySimpleTwitch.login_chat_anon(channel_name)
	VerySimpleTwitch.chat_message_received.connect(print_chatter_message)

func print_chatter_message(chatter):
	print("Message received from %s: %s" % [chatter.tags.display_name, chatter.message])
