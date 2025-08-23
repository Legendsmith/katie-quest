extends Node2D

@onready var text_node:RichTextLabel = $Anchor/Container/RichTextLabel
@onready var container:Container = $Anchor/Container
@onready var anchor:Node2D = $Anchor

const char_time:float = 0.02
const margin_offset:int = 4

func _ready() -> void:
	visible = false
	$Timer.timeout.connect(_on_Timer_timeout)

func set_text(text:String, wait_time = 2.5):
	visible = true
	$Timer.stop()
	text = text.trim_suffix(" ")
	text_node.bbcode_text = text

	# Duration
	var duration = text_node.text.length() * char_time
	anchor.position = Vector2.ZERO
	# Set the size of the speech bubble
	var text_size = text_node.get_theme_font("normal_font").get_string_size(text_node.text)
	container.add_theme_constant_override(&"margin_right", margin_offset)
	$Timer.wait_time = wait_time * (text_size.x * 0.15)
	var tween:Tween = get_tree().create_tween()
	tween.stop()
	# Animation
	text_node.visible_ratio=0.0
	container.size.x=0.0
	anchor.position.x=0.0
	tween.parallel().tween_property(text_node, ^"visible_ratio", 1, duration)
	tween.parallel().tween_property(container, ^"size:x", int(text_size.x+margin_offset), duration)
	tween.parallel().tween_property(anchor, ^"position", Vector2(-(text_size.x+margin_offset)/2,0), duration)
	tween.play()
	tween.finished.connect($Timer.start)

func _on_Timer_timeout() -> void:
	visible = false
