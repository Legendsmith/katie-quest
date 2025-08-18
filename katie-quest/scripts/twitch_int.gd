extends Node

signal emotes_loaded(emotes_data)
var channel_name: String = "obkatiekat"
var channel_id: String = "102860313"
var emotes: Dictionary = {}
var emotes_loaded_count: int = 0
var total_emotes: int = 0
var max_concurrent_downloads: int = 5
var current_downloads: int = 0
var download_queue: Array = []
func _ready():
	VerySimpleTwitch.login_chat_anon(channel_name)
	VerySimpleTwitch.chat_message_received.connect(print_chatter_message)
	load_existing_emotes()
	fetch_channel_emotes()
func print_chatter_message(chatter):
	print("Message received from %s: %s" % [chatter.tags.display_name, chatter.message])
func _on_emotes_data_received(
	_result: int,
	response_code: int,
	_headers: PackedStringArray,
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
	total_emotes = emotes_array.size()
	for emote in emotes_array:
		var emote_name = emote.name
		var emote_id = emote.id
		if emotes.has(emote_name):
			print("Emote already cached: ", emote_name)
			emotes_loaded_count += 1
			continue
		var emote_data = {
			"name": emote_name,
			"id": emote_id,
			"is_fallback": false
		}
		download_queue.append(emote_data)	
	process_download_queue()
func process_download_queue():
	while current_downloads < max_concurrent_downloads and download_queue.size() > 0:
		var emote_data = download_queue.pop_front()
		var format = ".avif" if not emote_data.is_fallback else ".webp"
		var image_url = "https://cdn.7tv.app/emote/" + emote_data.id + "/2x" + format
		current_downloads += 1
		download_emote_image(emote_data.name, image_url, emote_data.id, emote_data.is_fallback)
func download_emote_image(
	emote_name: String,
	image_url: String,
	emote_id: String = "",
	is_fallback: bool = false
):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_image_downloaded.bind(emote_name, emote_id, is_fallback, http_request))
	http_request.request(image_url)
func _on_image_downloaded(
	emote_name: String,
	http_request: HTTPRequest,
	emote_id: String,
	is_fallback: bool,
	_result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
):
	if response_code == 200:
		var image = Image.new()
		var error
		var file_extension
		if not is_fallback:
			error = image.load_from_buffer(body)
			file_extension = ".avif"
		else:
			error = image.load_webp_from_buffer(body)
			file_extension = ".webp"
		if error == OK:
				var texture = ImageTexture.create_from_image(image)
				emotes[emote_name] = texture
				save_emote_to_disk(emote_name, body, file_extension)
				emotes_loaded_count += 1
				if emotes_loaded_count % 10 == 0 or emotes_loaded_count >= total_emotes:
					print("Downloaded emotes: ", emotes_loaded_count, "/", total_emotes)
				if emotes_loaded_count >= total_emotes and download_queue.size() == 0:
					emotes_loaded.emit(emotes)
		else:
			print("Failed to load image for: ", emote_name)
	elif response_code == 404 and not is_fallback:
		var fallback_data = {
			"name": emote_name,
			"id": emote_id,
			"is_fallback": true
		}
		download_queue.push_front(fallback_data)
		current_downloads -= 1
		process_download_queue()
		http_request.queue_free()
		return
	else:
		print("Failed to download: ", emote_name, " - Code: ", response_code)
	current_downloads -= 1
	process_download_queue()
	http_request.queue_free()
func save_emote_to_disk(emote_name: String, image_data: PackedByteArray, extension: String = ".webp"):
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("emotes"):
		dir.make_dir("emotes")
	var file = FileAccess.open("user://emotes/" + emote_name + extension, FileAccess.WRITE)
	if file:
		file.store_buffer(image_data)
		file.close()
func load_existing_emotes():
	var dir = DirAccess.open("user://emotes/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".webp") or file_name.ends_with(".avif"):
				var emote_name = file_name.get_basename()
				var image = Image.new()
				if image.load("user://emotes/" + file_name) == OK:
					var texture = ImageTexture.create_from_image(image)
					emotes[emote_name] = texture
				file_name = dir.get_next()
func fetch_channel_emotes():
	print_debug("Attempting to fetch channel emotes")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var url: String = "https://7tv.io/v3/users/twitch/" + channel_id
	http_request.request_completed.connect(_on_emotes_data_received)
	http_request.request(url)
	print("Fetching emotes from: ", url)
func get_emote_texture(emote_name: String) -> ImageTexture:
	if emotes.has(emote_name):
		return emotes[emote_name]
	else:
		print("Emote not found: ", emote_name)
		return null
func has_emote(emote_name: String) -> bool:
	return emotes.has(emote_name)