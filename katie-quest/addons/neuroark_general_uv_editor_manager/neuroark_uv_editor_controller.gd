@tool
extends Node2D
class_name NeuroArkUVEditorController

signal canvas_zoom
signal weight_changed
signal checkbox_selected
signal polygon_2d_updated
signal vertices_count_changed
signal editor_scrolled
signal editor_opened
signal editor_closed
signal mouse_moved
signal mouse_moving
signal mouse_stopped
signal mouse_button_pressed
signal mouse_button_pressing
signal mouse_button_released

var selectedBoneIndex: int = -1
var MouseCoordinatesOffsetX: SpinBox = null
var MouseCoordinatesOffsetY: SpinBox = null
var editor: NeuroArkUVEditorView = null
#Data
var user_is_on_input_action: bool = false
var mouseLeftPressed: bool = false
var mouseCenterPressed: bool = false
var mouseRightPressed: bool = false
var boxGroupLoaded: bool = false
var mouseMoving: bool = false

func _init(_editor: NeuroArkUVEditorView):
	editor = _editor

func initialize_listeners():
	if Engine.get_version_info().hex < NeuroArkUVEditorView.GODOT_VER_4_3:
		if not editor.spinbox_spinZoom.value_changed.is_connected(zooming_canvas):
			editor.spinbox_spinZoom.value_changed.connect(zooming_canvas)
	if not NeuroArkNodeTools.has_function_attached(editor.button_show_hide_plugins.pressed, "show_hide_plugin") && not editor.button_show_hide_plugins.pressed.is_connected(show_hide_plugin):
		editor.button_show_hide_plugins.pressed.connect(show_hide_plugin)
	if not editor.editor_zoom_widget.zoom_changed.is_connected(zooming_canvas):
		editor.editor_zoom_widget.zoom_changed.connect(zooming_canvas)	
	if not editor.panel_editor.gui_input.is_connected(gui_input_in_editor):
		editor.panel_editor.gui_input.connect(gui_input_in_editor)
	if not editor.panel_editor.visibility_changed.is_connected(changed_visibility):
		editor.panel_editor.visibility_changed.connect(changed_visibility)
	if not editor.control_editor_container.gui_input.is_connected(gui_input_in_control):
		editor.control_editor_container.gui_input.connect(gui_input_in_control)
	if not editor.hslider_weight.value_changed.is_connected(changed_weight):
		editor.hslider_weight.value_changed.connect(changed_weight)
	if not editor.vscrollbar_editor.scrolling.is_connected(editor_scrolling.bind(editor.vscrollbar_editor.value, true)):
		editor.vscrollbar_editor.scrolling.connect(editor_scrolling.bind(editor.vscrollbar_editor.value, true))
	if not editor.hscrollbar_editor.scrolling.is_connected(editor_scrolling.bind(editor.hscrollbar_editor.value, false)):
		editor.hscrollbar_editor.scrolling.connect(editor_scrolling.bind(editor.hscrollbar_editor.value, false))
		
func close_listeners():
	if Engine.get_version_info().hex < NeuroArkUVEditorView.GODOT_VER_4_3:
		if editor.spinbox_spinZoom.value_changed.is_connected(zooming_canvas):
			editor.spinbox_spinZoom.value_changed.disconnect(zooming_canvas)
	if editor.button_show_hide_plugins.pressed.is_connected(show_hide_plugin):
		editor.button_show_hide_plugins.pressed.disconnect(show_hide_plugin)	
	if editor.editor_zoom_widget.zoom_changed.is_connected(zooming_canvas):
		editor.editor_zoom_widget.zoom_changed.disconnect(zooming_canvas)
	if editor.panel_editor.visibility_changed.is_connected(changed_visibility):
		editor.panel_editor.visibility_changed.disconnect(changed_visibility)
	if editor.hslider_weight.value_changed.is_connected(changed_weight):
		editor.hslider_weight.value_changed.disconnect(changed_weight)
	if editor.panel_editor.gui_input.is_connected(gui_input_in_editor):
		editor.panel_editor.gui_input.disconnect(gui_input_in_editor)
	if editor.control_editor_container.gui_input.is_connected(gui_input_in_control):
		editor.control_editor_container.gui_input.disconnect(gui_input_in_control)
	if editor.vscrollbar_editor.scrolling.is_connected(editor_scrolling):
		editor.vscrollbar_editor.scrolling.disconnect(editor_scrolling)
	if editor.hscrollbar_editor.scrolling.is_connected(editor_scrolling):
		editor.hscrollbar_editor.scrolling.disconnect(editor_scrolling)
	if editor.btn_group_radioGroup:
		if editor.btn_group_radioGroup.pressed.is_connected(selected_checkbox):
			editor.btn_group_radioGroup.pressed.disconnect(selected_checkbox)

func zooming_canvas(value:float):
	canvas_zoom.emit(value)

func vertices_count_updated():
	editor.panel_editor.get_parent().queue_redraw()
	vertices_count_changed.emit(editor.polygon2D)

func get_zoom_value()->float:
	if Engine.get_version_info().hex < NeuroArkUVEditorView.GODOT_VER_4_3:
		return editor.spinbox_spinZoom.value
	else:
		return editor.editor_zoom_widget.zoom

func selected_checkbox(btn:CheckBox):
	selectedBoneIndex = find_selected_checkbox_index(btn)
	checkbox_selected.emit(selectedBoneIndex)

func changed_weight(weight:float):
	weight_changed.emit(weight)

func editor_scrolling(value:float, vertical:bool):
	editor_scrolled.emit(value, vertical)

	##This function is neccesary as the checkbox group is created dinamically and it has to be disconnected before searching for the new one
func clear_checkbox_group():
	if editor.btn_group_radioGroup:
		editor.btn_group_radioGroup.pressed.disconnect(selected_checkbox)
		selectedBoneIndex = 0
		editor.btn_group_radioGroup = null

func show_hide_plugin():
	var visible = editor.original_main_radios_container.visible
	editor.original_main_radios_container.visible = !visible

func changed_visibility():
	visible = !visible
	#Im not quite sure why, but in godot 4.x this variable is inverted... it should be visible true to open it, and visible false to close it
	if visible:
		clear_checkbox_group()
		editor_closed.emit()
	else:
		validate_polygon2d()
		editor.get_checkbox_button_group()
		editor_opened.emit()

func validate_button_group()->String:
	if not editor.btn_group_radioGroup:
		return "Error: The checkbox group is not valid \n please, reselect the polygon and reopen \n the uv editor"
	if not NeuroArkMathTools.isNumberInRange(selectedBoneIndex, 0, editor.btn_group_radioGroup.get_buttons().size()):
		return "Error: Before continue, please select a bone checkbox"
	return ""

func general_button_group_validation()->bool:
	if not editor.btn_group_radioGroup:
		return false
	return true

func prepare_radio_buttons()->bool:
	var valid:bool = true
	if not editor.btn_group_radioGroup:
		selectedBoneIndex = -1 
		boxGroupLoaded = false
		valid = false
	elif editor.btn_group_radioGroup.get_buttons().size()==0:
		selectedBoneIndex = -1 
		boxGroupLoaded = false
		valid = false
		if editor.btn_group_radioGroup.pressed.is_connected(selected_checkbox):
			editor.btn_group_radioGroup.pressed.disconnect(selected_checkbox)
	if not valid:
		editor.reload_btn_radiobox()
#		editor.btn_group_radioGroup = NeuroArkUITools.find_checkbox_button_group(editor.original_main_radios_container)
		if editor.btn_group_radioGroup:
			selectedBoneIndex = 0
			if not editor.btn_group_radioGroup.pressed.is_connected(selected_checkbox):
				editor.btn_group_radioGroup.pressed.connect(selected_checkbox)
	return valid

func update_bone_weights():
	for bone in editor.polygon2D.get_bone_count():
		var temp: PackedFloat32Array
		var weights: PackedFloat32Array = editor.polygon2D.get_bone_weights(bone)
		for i in editor.polygon2D.polygon.size():
			if i < weights.size():
				temp.append(weights[i])
			else:
				temp.append(0)
		editor.polygon2D.set_bone_weights(bone, temp)

func redraw_editor():
	if not editor.hscrollbar_editor: return
	editor.control_editor_container.queue_redraw()
	editor.panel_editor.queue_redraw()
	editor.polygon2D.queue_redraw()

func find_selected_checkbox_index(btn:CheckBox):
	if btn:
		for i in editor.boneNames.size()-1:
			if btn.text == editor.boneNames[i]:
				return i
	if not editor.btn_group_radioGroup:
		return -1
	var buttons:Array[BaseButton] = editor.btn_group_radioGroup.get_buttons()
	var count:int = 0
	for button in buttons:
		if button.button_pressed:
			return count
		count = count + 1
	return - 1

func set_polygon_2d(pol: Polygon2D):
	editor.polygon2D = pol
	editor.fill_bone_names(pol)
	polygon_2d_updated.emit(pol)

func is_polygon2d_valid()->bool:
	if editor.polygon2D:
		return true
	return false

func _find_selected_checbox_index():
	return find_selected_checkbox_index(editor.btn_group_radioGroup.get_pressed_button())

##This function is made to find and prepare the polygon2D and the corresponding bone names
func validate_polygon2d()->bool:
	if is_polygon2d_valid():
		return true
	else:
		var tempPolygon = editor.find_polygon2d_in_nodes_selection()
		if tempPolygon:
			editor.polygon2D = tempPolygon
			polygon_2d_updated.emit(editor.polygon2D)
			editor.fill_bone_names(editor.polygon2D)
			return true
		else:
			editor.print_feedback("Error: The Polygon2D is empty. \n If the bones are not synchronized with this polygon, \n please clinck on synchronize bones  \n or go back to the editor and reselect this node.", Color.RED)
	return false

func get_editor_local_mouse_position()->Vector2:
	if editor.panel_editor:
		return editor.panel_editor.get_local_mouse_position()
	else:
		return Vector2(0,0)
	
func get_editor_global_mouse_position()->Vector2:
	if editor.panel_editor:
		return editor.panel_editor.get_global_mouse_position()
	else:
		return Vector2(0,0)

## This will call for the redraw of the number canvas each time the editorPanel has an input event
## ALso, this only handle the events in the editor, not in the canvas
func gui_input_in_editor(event:Object):
	if event is InputEventMouseMotion:
		mouse_moving.emit(event.position)

## This does actually handles the events in the canvas
func gui_input_in_control(event:Object):
	if event is InputEventMouseMotion:
		if event.velocity == Vector2(0,0):
			if mouseMoving == true:
				mouseMoving = false
				mouse_stopped.emit(event.position)
		else:
			if mouseMoving == false:
				mouseMoving = true
				mouse_moved.emit(event.position)
			else:
				mouse_moving.emit(event.position, event.velocity)
	elif event is InputEventMouseButton:
		mouseLeftPressed = handle_mouse_button(MOUSE_BUTTON_LEFT, mouseLeftPressed)
		mouseCenterPressed = handle_mouse_button(MOUSE_BUTTON_MIDDLE, mouseCenterPressed)
		mouseRightPressed = handle_mouse_button(MOUSE_BUTTON_RIGHT, mouseRightPressed)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN || event.button_index == MOUSE_BUTTON_WHEEL_LEFT || event.button_index == MOUSE_BUTTON_WHEEL_RIGHT || event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if Engine.get_version_info().hex < NeuroArkUVEditorView.GODOT_VER_4_3:
				zooming_canvas(editor.spinbox_spinZoom.value)
			else:
				zooming_canvas(editor.editor_zoom_widget.zoom)

func handle_mouse_button(buttonId:int, isPressed:bool)->bool:
	if visible: 
		return false
	if Input.is_mouse_button_pressed(buttonId):
		var localPos: Vector2 = get_editor_local_mouse_position()
		var globalPos: Vector2 = get_editor_global_mouse_position()
		if not isPressed:
			mouse_button_pressed.emit(buttonId, localPos, globalPos)
			return true
		else:
			mouse_button_pressing.emit(buttonId, localPos, globalPos)
			return true
	elif isPressed:
		mouse_button_released.emit(buttonId)
		return false
	return false

func create_mouse_coordinates_offset()->VBoxContainer:
	var vContainerMouseCoordinatesOffset = VBoxContainer.new()
	var hContainerMouseCoordinatesOffsetX = HBoxContainer.new()
	var labelMouseCoordinatesOffsetX = Label.new()
	labelMouseCoordinatesOffsetX.text = "X:"
	MouseCoordinatesOffsetX = SpinBox.new()
	MouseCoordinatesOffsetX.step = 0.1
	MouseCoordinatesOffsetX.value = 110
	MouseCoordinatesOffsetX.max_value = 300
	hContainerMouseCoordinatesOffsetX.add_child(labelMouseCoordinatesOffsetX)
	hContainerMouseCoordinatesOffsetX.add_child(MouseCoordinatesOffsetX)
	var hContainerMouseCoordinatesOffsetY = HBoxContainer.new()
	var labelMouseCoordinatesOffsetY = Label.new()
	labelMouseCoordinatesOffsetY.text = "Y:"
	MouseCoordinatesOffsetY = SpinBox.new()
	MouseCoordinatesOffsetY.step = 0.1
	MouseCoordinatesOffsetY.value = 500
	MouseCoordinatesOffsetY.max_value = 1000
	hContainerMouseCoordinatesOffsetX.add_child(labelMouseCoordinatesOffsetY)
	hContainerMouseCoordinatesOffsetX.add_child(MouseCoordinatesOffsetY)
	vContainerMouseCoordinatesOffset.add_child(hContainerMouseCoordinatesOffsetX)
	vContainerMouseCoordinatesOffset.add_child(hContainerMouseCoordinatesOffsetY)
	return vContainerMouseCoordinatesOffset

func show_mouse_in_all_cordinate_systems(control: Control):
	var editorGlobalPosition:Vector2 = get_global_mouse_position()
	var colorBlue: Color = Color.from_hsv(0.25, 1, 1, 0.75)
	var colorGreen: Color = Color.from_hsv(0.5, 1, 1, 0.75)
	var colorRed: Color = Color.from_hsv(0.75, 1, 1, 0.75)
	var colorYellow: Color = Color.from_hsv(1, 1, 1, 0.75)
	control.draw_circle(editorGlobalPosition, 15, colorBlue)
	control.draw_multiline_string(editor.font, editorGlobalPosition, "editorGlobalPosition", HORIZONTAL_ALIGNMENT_LEFT, 150, 15, 3, colorGreen)
	var editorLocalPosition:Vector2 = editor.editorPanel.get_local_mouse_position()
	control.draw_circle(editorLocalPosition, 15, colorGreen)
	control.draw_multiline_string(editor.font, editorLocalPosition, "editorLocalPosition", HORIZONTAL_ALIGNMENT_LEFT, 150, 15, 3, colorBlue)
	var polygonLocalPosition:Vector2 = editor.polygon2D.get_local_mouse_position()
	control.draw_circle(polygonLocalPosition, 15, colorYellow)
	control.draw_multiline_string(editor.font, polygonLocalPosition, "polygonLocalPosition", HORIZONTAL_ALIGNMENT_LEFT, 150, 15, 3, colorRed)
	var polygonGlobalPosition:Vector2 = editor.polygon2D.get_global_mouse_position()
	control.draw_circle(polygonGlobalPosition, 15, colorRed)
	control.draw_multiline_string(editor.font, polygonGlobalPosition, "polygonGlobalPosition", HORIZONTAL_ALIGNMENT_LEFT, 150, 15, 3, colorYellow)

func print_shape_row_operations_and_debug(direction:String, mousePoint:Vector2, distanceFactor: float, directionIndex:int, posX:float, posY:float, vertical:bool, at2: bool, at3: bool, at4: bool, at10: bool):
	var axisComplex:String
	var axisEasy: String
	var axisValueComplex: float
	var axisValueEasy: float
	if vertical:
		axisComplex = "y"
		axisEasy = "x"
		axisValueComplex = mousePoint.y
		axisValueEasy = mousePoint.x
	else:
		axisComplex = "x"
		axisEasy = "y"
		axisValueComplex = mousePoint.x
		axisValueEasy = mousePoint.y
	var msgPart0:String = direction + " => "
	var msgPart1:String =  "COMPLEX:\n"
	var msgPart2:String = "     mousePoint." + axisComplex + "[" + str(axisValueComplex) + "]"
	var msgPart3:String = " + " if at2 else " - "
	var msgPart4:String = " ("
	var msgPart5:String = "" if at3 else "-"
	var msgPart6:String = "distanceFactor["+str(distanceFactor) + "]"	
	var msgPart7:String = " + " if at4 else " - " 
	var msgPart8:String = "(distanceFactor[" + str(distanceFactor) + "] * leftToRightSide[" + str(directionIndex) + "])"
	var msgPart9:String = "[[Res:**"+str(distanceFactor * directionIndex)+"**]]"
	var msgPart10:String = ") "
	var msgPart11:String = "\n EASY: "
	var msgPart12:String = "     mousePoint." + axisEasy + "[" + str(axisValueEasy) + "] "
	var msgPart13:String = "+" if at10 else "-"
	var msgPart14:String = "distanceFactor" + " [" + str(distanceFactor) + "]"
	var msgPart15:String = "\n |"
	var msgPart16:String = "**[[Final POS X:=" + str(posX) + "]]**"
	var msgPart17:String = "**[[Final POS Y:=" + str(posY) + "]]**"
	print(msgPart0+msgPart1+msgPart2+msgPart3+msgPart4+msgPart5+msgPart6+msgPart7+msgPart8+msgPart9+msgPart10+msgPart11+msgPart12+msgPart13+msgPart14+msgPart15+msgPart16+msgPart17)

func find_who_has_size(node:Node):
	var msg = "Child:" + str(node.size) + "\n"
	var found:bool = false
	var parent: Node = node.get_parent()
	while not found:
		msg = msg + "Parent:" + str(parent.size) + "\n"
		parent = parent.get_parent()
		if not parent:
			found = true
		elif parent.size.x > 0 || parent.size.y > 0:
			found = true
	print(msg)
