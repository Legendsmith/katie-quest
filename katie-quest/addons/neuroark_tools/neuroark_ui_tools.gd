@tool
extends Node
class_name NeuroArkUITools
const MENU_2D_EDITOR_VBOX_INDEX = 4
static func remove_all_items_from_option_buttion(button: OptionButton):
	while button.item_count > 0:
		button.remove_item(0)

## Control tools
static func add_options_to_option_button(options: Array[String], button: OptionButton, replace: bool = false):
	if replace:
		remove_all_items_from_option_buttion(button)
	for option in options:
		button.add_item(option)

## Control creators
static func create_a_label(text:String, horizontalAligment:int, horizontalSizeFlag:int = Control.SIZE_EXPAND_FILL, verticalSizeFlag:int = Control.SIZE_SHRINK_CENTER, visibile:bool = true)->Label:
	var label:Label = Label.new()
	label.text = text
	label.horizontal_alignment = horizontalAligment
	label.size_flags_horizontal = horizontalSizeFlag
	label.size_flags_vertical = verticalSizeFlag
	label.visible = visibile
	return label

## Control creators
static func create_a_button(text:String, horizontalAligment:int, horizontalSizeFlag:int = Control.SIZE_EXPAND_FILL, verticalSizeFlag:int = Control.SIZE_SHRINK_CENTER, visibile:bool = true)->Button:
	var button:Button = Button.new()
	button.text = text
	button.alignment = horizontalAligment
	button.size_flags_horizontal = horizontalSizeFlag
	button.size_flags_vertical = verticalSizeFlag
	button.visible = visibile
	return button

static func create_a_spinbox(value:float, step:float, min:float, max:float)->SpinBox:
	var spin:SpinBox = SpinBox.new()
	spin.value = value
	spin.step = step
	spin.min_value = min
	spin.max_value = max
	return spin

static func create_a_hslider(value:float, step:float, min:float, max:float,  horizontalSizeFlag:int = Control.SIZE_EXPAND_FILL, verticalSizeFlag:int = Control.SIZE_SHRINK_CENTER, visibile:bool = true)->HSlider:
	var slider:HSlider = HSlider.new()
	slider.value = value
	slider.step = step
	slider.min_value = min
	slider.max_value = max
	slider.size_flags_horizontal = horizontalSizeFlag
	slider.size_flags_vertical = verticalSizeFlag
	return slider

static func create_file_dialog(filters: String, description:String, inUserData:bool, inFileSystem:bool, isDir:bool, isSaveEditor:bool, openMultiple:bool = false)->FileDialog:
	var filedialog:FileDialog = FileDialog.new()
	var system_access: int = 0
	if inUserData:
		system_access = 1
	if inFileSystem:
		system_access = 2
	var file_mode: int = 4
	if isDir:
		file_mode = 2
	elif isSaveEditor:
		file_mode = 4
	else:
		if openMultiple:
			file_mode = 1
		else:
			file_mode = 0
	filedialog.file_mode = file_mode
	filedialog.access = system_access
	filedialog.add_filter(filters, description)
	return filedialog


static func get_ui_item_upper_left_position(element:Control)->Vector2:
	var x = element.position.x - (element.get_rect().size.x/2)
	var y = element.position.y - (element.get_rect().size.y/2)
	return Vector2(x, y)
static func get_ui_item_upper_right_position(element:Control)->Vector2:
	var x = element.position.x + (element.get_rect().size.x/2)
	var y = element.position.y - (element.get_rect().size.y/2)
	return Vector2(x, y)
static func get_ui_item_lower_left_position(element:Control)->Vector2:
	var x = element.position.x - (element.get_rect().size.x/2)
	var y = element.position.y + (element.get_rect().size.y/2)
	return Vector2(x, y)		
static func get_ui_item_lower_right_position(element:Control)->Vector2:
	var x = element.position.x + (element.get_rect().size.x/2)
	var y = element.position.y + (element.get_rect().size.y/2)
	return Vector2(x, y)

static func get_position_alongside_top_baseline(hookElement:Control, newElement:Control, toLeft:bool, xOffset:float, yOffset:float)->Vector2:
	var x = hookElement.position.x
	var y = hookElement.position.y
	if toLeft:
		x = x - ((hookElement.get_rect().size.x/2) + (newElement.get_rect().size.x/2) + xOffset)
	else:
		x = x + (hookElement.get_rect().size.x/2) + (newElement.get_rect().size.x/2) + xOffset
	y + (hookElement.get_rect().size.y/2) - (newElement.get_rect().size.y/2) + yOffset
	return Vector2(x, y)

static func get_position_alongside_middle_baseline(hookElement:Control, newElement:Control, toLeft:bool, xOffset:float, yOffset:float)->Vector2:
	var x = hookElement.position.x
	var y = hookElement.position.y
	if toLeft:
		x = x - ((hookElement.get_rect().size.x/2) + (newElement.get_rect().size.x/2) + xOffset)
	else :
		x = x + (hookElement.get_rect().size.x/2) + (newElement.get_rect().size.x/2) + xOffset
	y = y + yOffset
	return Vector2(x, y)	

static func get_position_alongside_bottom_baseline(hookElement:Control, newElement:Control, toLeft:bool, xOffset:float, yOffset:float)->Vector2:
	var x = hookElement.position.x
	var y = hookElement.position.y
	if toLeft:
		x = x - ((hookElement.get_rect().size.x/2) + (newElement.get_rect().size.x/2) + xOffset)
	else:
		x = x + (hookElement.get_rect().size.x/2) + (newElement.get_rect().size.x/2) + xOffset
	y = y - (hookElement.get_rect().size.y/2) - (newElement.get_rect().size.y/2) + yOffset
	return Vector2(x, y)


static func find_editor_bottom_panel()-> Control:
	var bottom_panel = EditorInterface.get_base_control().find_children("*", "EditorBottomPanel", true, false)
	if bottom_panel:
		return bottom_panel[0]
	return null

static func find_editor_menu_2d_vbox(bottom_panel: Control)->VBoxContainer:
	var containerA = bottom_panel.find_children("*", "VBoxContainer", false, false)
	if containerA:
		var containerB = containerA[0].find_children("*", "VBoxContainer", false, false)
		if containerB:
			return containerB[get_menu_2d_editor_vbox_index()]
	return null

static func get_menu_2d_editor_vbox_index()->int:
	return MENU_2D_EDITOR_VBOX_INDEX

static func find_editor_menu_2d_hbox(menu_vbox: VBoxContainer)->HBoxContainer:
	var container = menu_vbox.find_children("*", "HBoxContainer", false, false)
	if container:
		return container[0]
	return null

static func find_editor_menu_2d_bottom_fourth(menu_hbox: HBoxContainer)->Button:
	var container = menu_hbox.find_children("*", "Button", false, false)
	if container:
		return container[3]
	return null

static func find_menu_2d()->HBoxContainer:
	var bottom_panel = find_editor_bottom_panel()
	var menu_vbox = find_editor_menu_2d_vbox(bottom_panel)
	var menu_hbox = find_editor_menu_2d_hbox(menu_vbox)
	return menu_hbox

static func find_menu_button_2d()->MenuButton:
	var bottom_panel = find_editor_bottom_panel()
	var menu_vbox = find_editor_menu_2d_vbox(bottom_panel)
	var menu_hbox = find_editor_menu_2d_hbox(menu_vbox)
	var container = menu_vbox.find_children("*", "MenuButton", true, false)
	if container:
		return container[0]
	return null	

static func find_menu_2d_button_for_hook()->Button:
	var bottom_panel = find_editor_bottom_panel()
	var menu_vbox = find_editor_menu_2d_vbox(bottom_panel)
	var menu_hbox = find_editor_menu_2d_hbox(menu_vbox)
	var button = find_editor_menu_2d_bottom_fourth(menu_hbox)
	return button

static func find_editor_bottom_menu_2d_spinbox(bottom_panel: Control)->SpinBox:
	var container = bottom_panel.find_children("*", "SpinBox", false, false)
	if container:
		return container[0]
	return null	

static func find_or_create_neuroark_editor_canvas() -> VBoxContainer:
	var container = EditorInterface.get_base_control().find_children("neuroark_uv_editor_container", "VBoxContainer", true, false)
	if not container:
		container = VBoxContainer.new()
		container.name = "neuroark_uv_editor_container"
	else:
		container = container[0]
	return container

# Search and gets the Polygon2D, which is the base of most of my plugins
static func find_polygon_2d()-> Polygon2D:
	var editors = EditorInterface.get_base_control().find_children("*", "Polygon2D", true, false)
	for editor in editors:
		if editor.get_parent() is Panel && editor.get_parent().get_child(1) is Control: #<-- Is the editor
			return editor
	return null

static func get_panel(polygon2D: Polygon2D)->Panel:
	return polygon2D.get_parent()

# Search and gets the widget that contains the radios in the editor
static func find_widget_radios(polygon2D: Polygon2D)-> VBoxContainer:
	return polygon2D.get_parent().get_parent().get_child(1)

static func get_synchronization_button(original_main_radios:VBoxContainer)-> Button:
	return original_main_radios.get_child(0)

static func find_external()-> HSplitContainer:
	var container = EditorInterface.get_base_control().find_children("neuroark_uv_editor_widget_split_external", "HSplitContainer", true, false)
	if container:
		return container[0]
	return null

# Search and gets the external container that will be used for the widget
static func create_external_and_reparent_radios(original_main_radios:VBoxContainer)->HSplitContainer:
	var external = find_external()
	if not external:
		external = HSplitContainer.new()
		external.dragger_visibility = 0
		var original_exact_radios = original_main_radios.get_child(1).get_child(0) # Gets actual radioContainer
		external.name = "neuroark_uv_editor_widget_split_external"
		if original_exact_radios:
			original_exact_radios.reparent(external)
			original_main_radios.get_child(1).add_child(external)
		return external
	else:
		return external

static func find_internal()-> HSplitContainer:
	var container = EditorInterface.get_base_control().find_children("neuroark_uv_editor_widget_split_internal", "HSplitContainer", true, false)
	if container:
		return container[0]
	return null

static func create_and_prepare_internal(external:HSplitContainer) -> HSplitContainer:
	var internal = find_internal()
	if not internal:
		internal = HSplitContainer.new()
		internal.name = "neuroark_uv_editor_widget_split_internal"
		internal.dragger_visibility = 0
		internal.dragging_enabled = true
		var firstSlot = VBoxContainer.new()
		firstSlot.name = "neuroark_uv_editor_widget_split_internal_first"
		firstSlot.size_flags_horizontal = VBoxContainer.SIZE_EXPAND_FILL
		var secondSlot = VBoxContainer.new()
		secondSlot.name = "neuroark_uv_editor_widget_split_internal_second"
		secondSlot.size_flags_horizontal = VBoxContainer.SIZE_EXPAND_FILL
		internal.add_child(firstSlot)
		internal.add_child(secondSlot)
		NeuroArkNodeTools.add_child_to_parent(internal, external)
		return internal
	else:
		return internal

static func get_internal_child(internal:HSplitContainer, secondSlot:bool)-> VBoxContainer:
	if secondSlot:
		return internal.get_child(1)
	return internal.get_child(0)

static func find_checkbox_button_group(original_main_radios: VBoxContainer) -> ButtonGroup:
	if not original_main_radios:
		return null
	var checkBoxes = original_main_radios.find_children("*", "CheckBox", true, false)
	for check in checkBoxes as Array[CheckBox]:
		if check.button_group:
			return check.button_group
	return null

static func prepare_editor_widget_all(secondSlot:bool) -> VBoxContainer:
	var polygon2D: Polygon2D = find_polygon_2d()
	var original_main_radios:VBoxContainer = find_widget_radios(polygon2D)
	var external:HSplitContainer = create_external_and_reparent_radios(original_main_radios)
	var internal:HSplitContainer = create_and_prepare_internal(external)
	return get_internal_child(internal, secondSlot)
