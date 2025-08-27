@tool
extends Node2D
class_name NeuroArkUVEditorView
const CANVAS_NAME: String = "neuroark_section_uv_editor"
const GODOT_VER_4_3 = 0x040300
const GODOT_VER_4_4 = 0x040400
const GODOT_VER_4_5 = 0x040500

var hsplit_container_neuroark_widget_external: HSplitContainer = null
var hsplit_container_neuroark_widget_internal: HSplitContainer = null
var vbox_container_neuroark_widget_first: VBoxContainer = null
var vbox_container_neuroark_widget_second: VBoxContainer = null
var vbox_neuroArkContainer: VBoxContainer = null
var vscrollbar_neuroark: VScrollBar = null
var vbox_mainContainer: VBoxContainer = null
var hbox_menuContainer: HBoxContainer = null
var hsplit_dualContainer: HSplitContainer = null
var original_main_radios_container: VBoxContainer = null
var vbox_radioGroupContainer: VBoxContainer = null
var btn_group_radioGroup: ButtonGroup = null
var button_synchronization: Button = null
var button_show_hide_plugins: Button = null
var panel_editor: Panel = null # The panel is the box that contains everything, including the editor and the bone section
var polygon2D: Polygon2D = null
var control_editor_container: Control = null # This is the editor container
var editor_zoom_widget: Control = null
var hslider_weight: HSlider = null
var	spinbox_spinZoom: SpinBox = null
var vscrollbar_editor: VScrollBar = null
var hscrollbar_editor: HScrollBar = null
signal print_feedback_on_screen

var font: Font
var boneNames: Array[String] = []

func initialize_editor():
	prepare_show_buttom()
	polygon2D = NeuroArkUITools.find_polygon_2d()
	panel_editor = polygon2D.get_parent()
	control_editor_container = panel_editor.get_child(1)
	hsplit_dualContainer = polygon2D.get_parent().get_parent()
	vbox_mainContainer = polygon2D.get_parent().get_parent().get_parent()
	hbox_menuContainer = vbox_mainContainer.get_child(0)
	editor_zoom_widget = find_zoom_widget()
	hslider_weight = find_h_slider(0)
	spinbox_spinZoom = find_spinbox(1)
	original_main_radios_container = NeuroArkUITools.find_widget_radios(polygon2D)
	hsplit_container_neuroark_widget_external = NeuroArkUITools.create_external_and_reparent_radios(original_main_radios_container)
	hsplit_container_neuroark_widget_internal = NeuroArkUITools.create_and_prepare_internal(hsplit_container_neuroark_widget_external)
	vbox_container_neuroark_widget_first = NeuroArkUITools.get_internal_child(hsplit_container_neuroark_widget_internal, false)
	vbox_container_neuroark_widget_second = NeuroArkUITools.get_internal_child(hsplit_container_neuroark_widget_internal, true)
	vbox_neuroArkContainer = NeuroArkUITools.find_or_create_neuroark_editor_canvas()
	btn_group_radioGroup = NeuroArkUITools.find_checkbox_button_group(original_main_radios_container)
	button_synchronization = NeuroArkUITools.get_synchronization_button(original_main_radios_container)
	vscrollbar_editor = control_editor_container.get_child(1)
	hscrollbar_editor = control_editor_container.get_child(2)
	add_child_to_editor_section(vbox_neuroArkContainer)
	add_child_to_hsplit_widget_section(hsplit_container_neuroark_widget_internal)

func remove_editor():
	remove_child_from_editor_section(vbox_neuroArkContainer)
	remove_child_from_hsplit_widget_section(hsplit_container_neuroark_widget_internal)
	polygon2D = null
	panel_editor = null
	control_editor_container = null
	hsplit_dualContainer = null
	vbox_mainContainer = null
	hbox_menuContainer = null
	editor_zoom_widget = null
	hslider_weight = null
	btn_group_radioGroup = null
	spinbox_spinZoom = null
	original_main_radios_container = null
	button_synchronization = null
	vbox_radioGroupContainer = null
	vscrollbar_editor = null
	hscrollbar_editor = null
	
func find_zoom_widget() -> Node:
	var widgets = panel_editor.find_children("*", "EditorZoomWidget", true, false)
	var widget: Node = widgets[0]
	return widget

func find_h_slider(index:int)->HSlider:
	var sliders = hbox_menuContainer.find_children("*", "HSlider", true, false)
	var count:int = -1
	for slider in sliders as Array[HSlider]:
		count = count + 1
		if index == count:
			return slider
	return null

func find_v_scrollbar() -> VScrollBar:
	var scrollContainters = panel_editor.find_children("*", "VScrollBar", true, false)
	for container in scrollContainters as Array[VScrollBar]:
		return container
	return null

func find_h_scrollbar() -> HScrollBar:
	var scrollContainters = panel_editor.find_children("*", "HScrollBar", true, false)
	for container in scrollContainters as Array[HScrollBar]:
		return container
	return null

func find_spinbox(index:int) -> SpinBox:
	var spinBoxes = hbox_menuContainer.find_children("*", "SpinBox", true, false)
	if index >= spinBoxes.size():
		return
	var count:int = -1
	for spin in spinBoxes as Array[SpinBox]:
		count = count + 1
		if index == count:
			return spin
	return null

func find_polygon2d_in_nodes_selection()->Polygon2D:
	var selectedNodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	for node in selectedNodes:
		if node is Polygon2D:
			return node
	return null

func reload_btn_radiobox():
	btn_group_radioGroup = NeuroArkUITools.find_checkbox_button_group(original_main_radios_container)

func get_or_create_canvas() -> Control:
	if not panel_editor:
		print_feedback("Error in the editor panel...", Color.RED)
		return null
	var path: NodePath = panel_editor.get_path()
	var canvasPath: NodePath = NodePath(path.get_concatenated_names()+"/"+CANVAS_NAME)
	if  panel_editor.has_node(canvasPath):
		return  panel_editor.get_node(canvasPath)
	else:
		var tempCanvas = Control.new()
		tempCanvas.name = CANVAS_NAME
		tempCanvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tempCanvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
		return tempCanvas

func get_or_create_main_container(offset:float)->VBoxContainer:
	var path: NodePath =  panel_editor.get_path()
	var vContainerMainPath: NodePath = NodePath(path.get_concatenated_names() + "/" + CANVAS_NAME + "/" + "NeuroArkUVEditorContainer")
	# Shapes Section
	if  panel_editor.has_node(vContainerMainPath):
		return  panel_editor.get_node(vContainerMainPath)
	else:
		var vContainerMain = VBoxContainer.new()
		vContainerMain.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vContainerMain.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vContainerMain.name = "NeuroArkUVEditorContainer"
		vContainerMain.global_position.y = vContainerMain.global_position.y + offset 
		return vContainerMain

func get_or_create_plugin_container()->VBoxContainer:
	var path: NodePath = panel_editor.get_path()
	var vContainerPerfectVertices2DPath: NodePath = NodePath(path.get_concatenated_names() + "/" + CANVAS_NAME  + "/" + "NeuroArkUVEditorContainer" + "/" + "VContainerPerfectVertices2D")
	if panel_editor.has_node(vContainerPerfectVertices2DPath):
		return panel_editor.get_node(vContainerPerfectVertices2DPath)
	else:
		var vContainerPerfectVertices2D = VBoxContainer.new()
		vContainerPerfectVertices2D.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vContainerPerfectVertices2D.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vContainerPerfectVertices2D.name = "VContainerPerfectVertices2D"
		return vContainerPerfectVertices2D

func get_checkbox_button_group() -> ButtonGroup:
	if btn_group_radioGroup:
		return btn_group_radioGroup
	return NeuroArkUITools.find_checkbox_button_group(original_main_radios_container)

func prepare_show_buttom():
	var menu = NeuroArkUITools.find_menu_2d()
	var button = menu.find_children("neuroark_uv_editor_show_hide_button", "Button", true, false)
	if not button:
		button_show_hide_plugins = Button.new()
		button_show_hide_plugins.text = "neuroark"
		button_show_hide_plugins.name = "neuroark_uv_editor_show_hide_button"	
		button_show_hide_plugins.visible = true
		var buttonFourth: Button = NeuroArkUITools.find_menu_2d_button_for_hook()
		buttonFourth.add_sibling(button_show_hide_plugins)
	else:
		button_show_hide_plugins = button[0]	

func fill_bone_names(polygon:Polygon2D):
	boneNames.clear()
	var count = polygon.get_bone_count()
	for i in count-1:
		var nodePath: NodePath = polygon.get_bone_path(i)
		var name:String = nodePath.get_name(nodePath.get_name_count()-1)
		boneNames.append(name)

func add_child_to_main_container(node: Node):
	add_child_to_parent(node, vbox_mainContainer)

func add_child_to_editor_section(node: Node):
	add_child_to_parent(node, control_editor_container)

func add_child_to_bones_radios_section(node: Node):
	add_child_to_parent(node, original_main_radios_container)

func add_child_to_zoom_widget(node: Node):
	add_child_to_parent(node, editor_zoom_widget)

func add_child_to_panel(node: Node):
	add_child_to_parent(node, panel_editor)

func add_child_to_neuroark_container(node: Node):
	add_child_to_parent(node, vbox_neuroArkContainer)

func add_child_to_hsplit_widget_section(node: Node):
	add_child_to_parent(node, hsplit_container_neuroark_widget_external)

func add_child_to_neuroark_scroll_widget_in_bones_radios_section(node: Node, secondWidgetSlot:bool):
	if secondWidgetSlot:
		add_child_to_parent(node, vbox_container_neuroark_widget_second)
	else:
		add_child_to_parent(node, vbox_container_neuroark_widget_first)

func add_child_to_parent(node: Node, parent: Node):
	var result = NeuroArkNodeTools.add_child_to_parent(node, parent)
	if result != "":
		print_feedback(result, Color.RED)

func remove_child_from_main_container(node: Node):
	remove_child_from_parent(node, vbox_mainContainer)

func remove_child_from_editor_section(node: Node):
	remove_child_from_parent(node, control_editor_container)

func remove_child_from_bones_radios_section(node: Node):
	remove_child_from_parent(node, original_main_radios_container)

func remove_child_from_zoom_widget(node: Node):
	remove_child_from_parent(node, editor_zoom_widget)

func remove_child_from_panel(node: Node):
	remove_child_from_parent(node, panel_editor)

func remove_child_from_neuroark_container(node: Node):
	remove_child_from_parent(node, vbox_neuroArkContainer)

func remove_child_from_hsplit_widget_section(node: Node):
	remove_child_from_parent(node, hsplit_container_neuroark_widget_external)

func remove_child_from_neuroark_scroll_widget_in_bones_radios_section(node: Node, secondWidgetSlot:bool):
	if secondWidgetSlot:
		remove_child_from_parent(node, vbox_container_neuroark_widget_second)
	else:
		remove_child_from_parent(node, vbox_container_neuroark_widget_first)	

func remove_child_from_parent(node: Node, parent: Node):
	var result = NeuroArkNodeTools.remove_child_from_parent(node, parent)
	if result != "":
		print_feedback(result, Color.RED)

func initialize_default_data():
	font = panel_editor.get_theme_font("panel")

func print_feedback(msg: String, color:Color):
	print_feedback_on_screen.emit(msg, color)
	
func get_label_font()->Font:
	return font

func get_title_color()->Color:
	return Color.from_hsv(0.60, 0.8, 0.95, 1)
