@tool
extends EditorPlugin
var visibility_button_menu: Button = null
var visibility_button_side_left: Button = null
var visibility_button_side_rigth: Button = null
var visibility_button_bottom: Button = null

func _enter_tree():
	var dummy = 1 + 1
#	if !visibility_button_menu:
#		crear_menu_item(visibility_button_menu, _on_button_pressed_menu, "Accion boton menú", EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU)
#		crear_menu_item(visibility_button_side_left, _on_button_pressed_lado_derecho, "Accion boton lado izquierdo", EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_LEFT)
#		crear_menu_item(visibility_button_side_rigth, _on_button_pressed_lado_izquierdo, "Accion boton lado derecho", EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT)
#		crear_menu_item(visibility_button_bottom, _on_button_pressed_abajo, "Accion boton abajo", EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM)
#		add_control_to_container()

func _exit_tree():
	var dummy = 1 + 1
#	eliminar_menu_item(visibility_button_menu, _on_button_pressed_menu, EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU)
#	eliminar_menu_item(visibility_button_side_left, _on_button_pressed_lado_derecho, EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_LEFT)
#	eliminar_menu_item(visibility_button_side_rigth, _on_button_pressed_lado_izquierdo, EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT)
#	eliminar_menu_item(visibility_button_bottom, _on_button_pressed_abajo, EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM)
		
func _has_main_screen():
	return false


func crear_menu_item(boton: Button, callback, message: String, contenedorIndex: CustomControlContainer):
	if !boton:
		boton = Button.new()
		boton.text = message
		boton.focus_mode = Control.FOCUS_NONE
		boton.flat = true
		boton.pressed.connect(callback)	
		add_control_to_container(contenedorIndex, boton)

func eliminar_menu_item(boton: Button, callback, contenedorIndex: CustomControlContainer):
	if boton:
		boton.pressed.disconnect(callback)
		remove_control_from_container(contenedorIndex, boton)

func _on_button_pressed_menu():
	NeuroArkNodeTools.print_debug_message("_on_button_pressed_menu","click")
	NeuroArkNodeTools.print_godot_structure_direct("estructura", NeuroArkNodeTools.get_godot_editor_version())

func _on_button_pressed_lado_derecho():
	NeuroArkNodeTools.print_debug_message("_on_button_pressed_lado_derecho","click")

func _on_button_pressed_lado_izquierdo():
	NeuroArkNodeTools.print_debug_message("_on_button_pressed_lado_izquierdo","click")

func _on_button_pressed_abajo():
	NeuroArkNodeTools.print_debug_message("_on_button_pressed_abajo","click")
