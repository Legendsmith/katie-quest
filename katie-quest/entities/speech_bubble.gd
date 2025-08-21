extends Node2D

@onready var text_node:RichTextLabel = $Anchor/MarginContainer/RichTextLabel
@onready var margin:MarginContainer = $Anchor/MarginContainer
@onready var text_bg:Panel = $Anchor/MarginContainer/TextBackground
@onready var anchor:Node2D = $Anchor

const char_time = 0.02
const margin_offset = 8

func _ready() -> void:
	visible = false
	set_text("test lmao")

func set_text(text, wait_time = 3):
	visible = true

	$Timer.wait_time = wait_time
	$Timer.stop()
	
	text_node.bbcode_text = text
	
	# Duration
	var duration = text_node.text.length() * char_time
	anchor.position = Vector2.ZERO
	# Set the size of the speech bubble
	var text_size = text_node.get_theme_font("normal_font").get_string_size(text_node.text)
	margin.add_theme_constant_override(&"margin_right", margin_offset)
	
	var tween:Tween = get_tree().create_tween()
	# Animation
	tween.tween_property(text_node, ^"visible_ratio", 1, duration)
	tween.tween_property(margin, ^"size:x", int(text_size.x), duration)
	tween.tween_property(anchor, ^"position", Vector2(-(text_size.x)/4,0), duration)
	tween.finished.connect($Timer.start)

func _on_Timer_timeout() -> void:
	visible = false
