extends Node

var abilities = {
	"blackhole": {
		"display_name": "Black Hole",
		"cooldown": 15.0,
		"ready": true,
		"obtained": false,
		"timer": null,
	},
	"guitar_solo": {
		"display_name": "Guitar Solo",
		"cooldown": 5.0,
		"ready": true,
		"obtained": true,
		"timer": null,
	},
	"bfg_9000": {
		"display_name": "BFG-9000",
		"cooldown": 10.0,
		"ready": true,
		"obtained": false,
		"timer": null,
	},
}

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Y:
				use_ability("blackhole")
			KEY_U:
				use_ability("guitar_solo")
			KEY_I:
				use_ability("bfg_9000")

func use_ability(ability_name: String):
	var display_name = abilities[ability_name].display_name

	if not abilities[ability_name].obtained:
		print("Ability ", display_name, " was not yet obtained!")
		return

	if abilities[ability_name].ready:
		abilities[ability_name].ready = false

		print("Ability ", display_name, " was used!")

		start_cooldown(ability_name)

	else:
		var remaining_cooldown = abilities[ability_name].timer.time_left

		var formatted_time = str(snapped(remaining_cooldown, 0.1))

		print(display_name, " is on cooldown! ", formatted_time, " seconds remaining")

func start_cooldown(ability_name: String):
	var timer = Timer.new()
	add_child(timer)

	timer.wait_time = abilities[ability_name].cooldown
	timer.one_shot = true
	timer.timeout.connect(_on_cooldown_finished.bind(ability_name, timer))

	abilities[ability_name].timer = timer

	timer.start()

func _on_cooldown_finished(ability_name: String, timer: Timer):
	abilities[ability_name].ready = true
	abilities[ability_name].timer = null

	timer.queue_free()

func can_use_ability(ability_name: String) -> bool:
	return abilities[ability_name].ready
