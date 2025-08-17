extends Node

signal emotes_loaded(emotes_data)

var channel_name: String = "obkatiekat"
var channel_id: String = "102860313"

var emotes: Dictionary = {}

func _ready():
	VerySimpleTwitch.login_chat_anon(channel_name)
	VerySimpleTwitch.chat_message_received.connect(print_chatter_message)

	fetch_channel_emotes()

func print_chatter_message(chatter):
	print("Message received from %s: %s" % [chatter.tags.display_name, chatter.message])

func fetch_channel_emotes():
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var url: String = "https://7tv.io/v3/users/twitch/" + channel_id
	http_request.request_completed.connect(_on_emotes_data_received)
	http_request.request(url)

	print("Fetching emotes from: ", url)

func _on_emotes_data_received(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())

		if parse_result == OK:
			var data = json.data

			if data.has("emote_set") and data.emote_set.has("emotes"):
				process_emotes(data.emote_set.emotes)
			else:
				print("No emotes found for this channel")

		else:
			print("Failed to parse JSON")

	else:
		print("HTTP request failed: ", response_code)

func process_emotes(emotes_array):
	print("Found ", emotes_array.size(), " emotes:")

	for emote in emotes_array:
		var emote_name = emote.name
		var emote_id = emote.id
		var image_url = "https://cdn.7tv.app/emote/" + emote_id + "/2x.webp"

		print("Emote: ", emote_name, " | URL: ", image_url)

		download_emote_image(emote_name, image_url)

func download_emote_image(emote_name: String, image_url: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(_on_image_downloaded.bind(emote_name, http_request))
	http_request.request(image_url)

func _on_image_downloaded(
	emote_name: String,
	http_request: HTTPRequest,
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
):
	if response_code == 200:
		var image = Image.new()
		var error = image.load_webp_from_buffer(body)

		if error == OK:
			var texture = ImageTexture.create_from_image(image)

			save_emote_to_disk(emote_name, body)

			print("Donwloaded emote: ", emote_name)

		else:
			print("Failed to load image for: ", emote_name)

	else:
		print("Failed to download: ", emote_name)

	http_request.queue_free()

func save_emote_to_disk(emote_name: String, image_data: PackedByteArray):
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("emotes"):
		dir.make_dir("emotes")

	var file = FileAccess.open("user://emotes/" + emote_name + ".webp", FileAccess.WRITE)
	if file:
		file.store_buffer(image_data)
		file.close()
		print("Saved emote to: user://emotes/" + emote_name + ".webp")
