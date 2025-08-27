@tool
extends EditorPlugin

var main_panel_instance
var container_instance: VBoxContainer = null
var parent_container: VBoxContainer = null
var polygon2D: Polygon2D = null
var panel_editor: Panel = null
var button_show: Button = null
var menu: HBoxContainer = null
var visibility: bool = false
func _enter_tree():
	main_panel_instance = preload("res://addons/vertices_and_weights_2d_swapper/vertices_and_weights_2d_swapper.tscn").instantiate()
	container_instance = main_panel_instance.get_node("VBoxContainerMain")
	container_instance.connect("refresh_screen", refresh_screen)
	parent_container = NeuroArkUITools.prepare_editor_widget_all(false)
	polygon2D = NeuroArkUITools.find_polygon_2d()
	panel_editor = NeuroArkUITools.get_panel(polygon2D)
	var original_main_radios_container: VBoxContainer = NeuroArkUITools.find_widget_radios(polygon2D)
	var button_synchronization: Button = NeuroArkUITools.get_synchronization_button(original_main_radios_container)
	if button_synchronization:
		button_synchronization.pressed.connect(container_instance.fill_bone_containers)
	NeuroArkNodeTools.add_child_to_parent(main_panel_instance, parent_container)
	prepare_show_buttom()
	set_visibility()
	refresh_screen()

func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	container_instance.disconnect("refresh_screen", refresh_screen)
	NeuroArkNodeTools.remove_child_from_parent(main_panel_instance, main_panel_instance)
	
func _has_main_screen():
	return false
	
func set_visibility():
	if main_panel_instance:
		visibility = !visibility
		main_panel_instance.visible = visibility
		if not visibility:
			button_show.text = "show swapper"
		else:
			button_show.text = "hide swapper"

func refresh_screen():
	if panel_editor.is_visible_in_tree():
		panel_editor.queue_redraw()

func _handles(object: Object) -> bool:
	if object is Polygon2D:
		if container_instance != null:
			object.get_parent()
			container_instance.polygon2d = object
			container_instance.fill_bone_containers()
		return true
	return false

func prepare_show_buttom():
	var radios = NeuroArkUITools.find_widget_radios(polygon2D)
	menu = NeuroArkUITools.find_menu_2d()
	button_show = Button.new()
	button_show.name = "neuroark_show_swapper_button"
	button_show.text = "hidde swapper"
	button_show.visible = true
	button_show.pressed.connect(set_visibility)
	var syncButton: Button = NeuroArkUITools.get_synchronization_button(radios)
	NeuroArkNodeTools.attach_and_reparent_control(button_show, syncButton, HBoxContainer.new(), false)
