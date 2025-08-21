extends Node

var cursors: Dictionary = {
  "Default": preload("res://texture/cursor/Default.png"),
  "Aim": preload("res://texture/cursor/Aim.png"),
  "Interact": preload("res://texture/cursor/Interact.png"),
  "Cant_Interact": preload("res://texture/cursor/Cant_Interact.png"),
}

func set_cursor(type: String = "Default", hotspot: Vector2 = Vector2.ZERO):
  Input.set_custom_mouse_cursor(cursors[type], Input.CURSOR_ARROW, hotspot)
