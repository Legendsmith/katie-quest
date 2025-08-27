@tool
extends Node2D
class_name  NeuroArkGeneralUVEditorManager

const SINGLETON_NAME = "NeuroArkUVEditor"

static var instance: NeuroArkGeneralUVEditorManager = null

static func getInstance()->NeuroArkGeneralUVEditorManager:
	if not instance:
		instance = NeuroArkGeneralUVEditorManager.new()
	return instance

static var activePlugins: Array[NeuroArkGeneralUVEditorRegisterModel] = []

var editorView: NeuroArkUVEditorView = null
var editorController: NeuroArkUVEditorController = null

func initialize_plugin():
	editorView = NeuroArkUVEditorView.new()
	editorController = NeuroArkUVEditorController.new(editorView)
	editorView.initialize_editor()
	editorController.initialize_listeners()
	editorView.initialize_default_data()

func remove_plugin():
	if NeuroArkGeneralUVEditorManager.activePlugins.size() == 0:
		editorController.close_listeners()
		editorView.remove_editor()

func _has_main_screen():
	return false

####### UI GETTERS ########
func get_editor()->Panel:
	return editorView.panel_editor

func get_main_container(canvasOffset)->VBoxContainer:
	return editorView.vbox_mainContainer

func get_radio_buttons_group()->ButtonGroup:
	return editorView.btn_group_radioGroup

func get_plugin_container()->VBoxContainer:
	return editorView.get_or_create_plugin_container()

func get_polygon_2d()->Polygon2D:
	return editorView.polygon2D

func get_the_canvas()->Control:
	return editorView.get_or_create_canvas()

func get_weight_slider()->HSlider:
	return editorView.hslider_weight

func get_button_synchronization()->Button:
	return editorView.button_synchronization

####### VALUE GETTERS ########
func get_editor_mouse_position(global: bool)->Vector2:
	if global:
		return editorController.get_editor_global_mouse_position()
	return editorController.get_editor_local_mouse_position()

func get_h_scrollbar_value()->float:
	return editorView.hscrollbar_editor.value

func get_mouse_position(global: bool):
	if global:
		return editorController.get_global_mouse_position()
	return editorController.get_local_mouse_position()

func get_selected_bone_index()->int:
	return editorController.selectedBoneIndex

func get_title_color()->Color:
	return editorView.get_title_color()

func get_v_scrollbar_value()->float:
	return editorView.vscrollbar_editor.value

func get_zoom_value()->float:
	return editorController.get_zoom_value()

####### VALIDATORS ########
func validate_polygon2d()->bool:
	return editorController.validate_polygon2d()

func validate_radio_buttons(showAlert:bool)->String:
	var result = editorController.validate_button_group()
	if result != "":
		var prepared = editorController.prepare_radio_buttons()
		if prepared:
			result = editorController.validate_button_group()
	return result

func general_button_group_validation()->bool:
	return editorController.general_button_group_validation()

####### ACTIONS ########
func redraw_editor():
	editorController.redraw_editor()

func print_feedback(msg:String, color: Color):
	editorView.print_feedback(msg, color)

func update_bone_weights():
	editorController.update_bone_weights()

func vertices_count_updated():
	editorController.vertices_count_updated()

static func register_editor(editor: NeuroArkGeneralUVEditorRegisterModel):
	NeuroArkArrayTools.add_item_to_array(activePlugins, editor)

static func unregister_editor(id: String):
	var editor:NeuroArkGeneralUVEditorRegisterModel = get_registered_editor(id)
	if editor:
		NeuroArkArrayTools.remove_item_from_array(activePlugins, editor)

static func get_registered_editor(id: String)->NeuroArkGeneralUVEditorRegisterModel:
	for i in activePlugins.size():
		if activePlugins[i].editorID == id:
			return activePlugins[i]
	return null

####### ADD COMPONENTS ########
func add_plugin_to_screen(node: Node):
	editorView.add_child_to_neuroark_container(node)

func add_child_to_panel(node:Node):
	editorView.add_child_to_panel(node)

func add_child_to_editor_section(node:Node):
	editorView.add_child_to_editor_section(node)

func add_child_to_zoom_widget(node:Node):
	editorView.add_child_to_zoom_widget(node)

func add_child_to_bones_radios_section(node:Node):
	editorView.add_child_to_bones_radios_section(node)

func add_child_to_neuroark_scroll_widget_in_bones_radios_section(node:Node, secondWidgetSlot:bool):
	editorView.add_child_to_neuroark_scroll_widget_in_bones_radios_section(node, secondWidgetSlot)

####### REMOVE COMPONENTS ########
func remove_plugin_from_screen(node: Node):
	editorView.remove_child_from_neuroark_container(node)

func remove_child_from_panel(node: Node):
	editorView.remove_child_from_panel(node)

func remove_child_from_editor_section(node: Node):
	editorView.remove_child_from_editor_section(node)

func remove_child_from_zoom_widget(node: Node):
	editorView.remove_child_from_zoom_widget(node)

func remove_child_from_bones_radios_section(node: Node):
	editorView.remove_child_from_bones_radios_section(node)

func remove_child_from_neuroark_scroll_widget_in_bones_radios_section(node:Node, secondWidgetSlot:bool):
	editorView.remove_child_from_neuroark_scroll_widget_in_bones_radios_section(node, secondWidgetSlot)
