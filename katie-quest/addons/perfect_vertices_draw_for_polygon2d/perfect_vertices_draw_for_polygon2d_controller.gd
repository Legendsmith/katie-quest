@tool
extends Node2D
class_name PerfectVerticesForPolygon2DController
#This is the minimum number of vertices to sorround a main vertext at mouse point
const BASE_FORM_FACTOR: int = 8
var hideVertices: bool = false
var isShapeApplyHovered: bool = false
var isControllerHovered: bool = false
var shapeVertices: PackedVector2Array
var shapeVisible: bool = false
var procesingRedraw: bool = false
var mouse_on_screen = false
var mouse_pressed_right = false
var mouse_pressed_left = false
var shapeIndex: int = PerfectVerticesForPolygon2DView.SHAPE_CIRCLE
var mousePosition: Vector2
var mousePositionStopped: Vector2
var zoom:float
var uvEditorManager:NeuroArkGeneralUVEditorManager
var editor:PerfectVerticesForPolygon2DView
var canvasOffset:float = 10

func _init(editorManager:NeuroArkGeneralUVEditorManager, _editor: PerfectVerticesForPolygon2DView):
	uvEditorManager = editorManager
	editor = _editor

func initialize_listeners():
	# Is the plugin canvas the one drawing, so it should be the one that has this connection
	connect_action(editor.pluginCanvas.draw, process_draw)
	connect_action(uvEditorManager.editorController.canvas_zoom, canvas_zoom)
	connect_action(uvEditorManager.editorController.editor_opened, visibility_changed.bind(true))
	connect_action(uvEditorManager.editorController.editor_closed, visibility_changed.bind(false))
	# mouse
	connect_action(uvEditorManager.editorController.mouse_moved, mouse_moved)
	connect_action(uvEditorManager.editorController.mouse_moving, mouse_moving)
	connect_action(uvEditorManager.editorController.mouse_stopped, mouse_stopped)
	connect_action(uvEditorManager.editorController.mouse_button_pressed, mouse_button_pressed)
	connect_action(uvEditorManager.editorController.mouse_button_pressing, mouse_button_pressing)
	connect_action(uvEditorManager.editorController.mouse_button_released, mouse_button_released)
	# new
	connect_action_and_hover(editor.addVerticesInShapeButton, editor.addVerticesInShapeButton.button_up, create_shape_form_button_click)
	connect_action_and_hover(editor.hSliderShapeRotation, editor.hSliderShapeRotation.value_changed, update_rotation.bind(editor.hSliderShapeRotation))
	connect_action_and_hover(editor.spinBoxShapeRotation, editor.spinBoxShapeRotation.value_changed, update_rotation.bind(editor.spinBoxShapeRotation))
	connect_action_and_hover(editor.spinVertexDistance, editor.spinVertexDistance.value_changed, vertex_distance_changed)
	connect_action_and_hover(editor.spinBoxLayerQuantity, editor.spinBoxLayerQuantity.value_changed, layer_quantity_changed)
	connect_action_and_hover(editor.spinBoxCirclePointsQuantity, editor.spinBoxCirclePointsQuantity.value_changed, circle_points_quantity_changed)
	connect_action_and_hover(editor.spinBoxLinePointsQuantity, editor.spinBoxLinePointsQuantity.value_changed, line_points_quantity_changed)
	connect_action_and_hover(editor.shapeActionButton, editor.shapeActionButton.button_up, apply_changes_to_polygon2D)
	connect_action_and_hover(editor.buttonTriangulatePolygons, editor.buttonTriangulatePolygons.pressed, triagulate_polygons)
	connect_action_and_hover(editor.optionsShapesVertices, editor.optionsShapesVertices.item_selected, change_shape)
	connect_hover(editor.checkInside)
	connect_hover(editor.pluginCanvas)
	#save
	connect_action(editor.dialogSave.file_selected, save_polygon2d_to_json)
	connect_action(editor.dialogLoad.file_selected, load_polygon2d_from_json)
	connect_action(editor.buttonSaveToJson.pressed, open_save_editor)
	connect_action(editor.buttonLoadFromJson.pressed, open_load_editor)

func close_listeners():
	# disconecting events from editor panel controls
	disconnect_action(editor.pluginCanvas.draw, process_draw)
	# new
	disconnect_action_and_hover(editor.addVerticesInShapeButton, editor.addVerticesInShapeButton.button_up, create_shape_form_button_click)
	disconnect_action_and_hover(editor.hSliderShapeRotation, editor.hSliderShapeRotation.value_changed, update_rotation)
	disconnect_action_and_hover(editor.spinBoxShapeRotation, editor.spinBoxShapeRotation.value_changed, update_rotation)
	disconnect_action_and_hover(editor.spinVertexDistance, editor.spinVertexDistance.value_changed, vertex_distance_changed)
	disconnect_action_and_hover(editor.spinBoxLayerQuantity, editor.spinBoxLayerQuantity.value_changed, layer_quantity_changed)
	disconnect_action_and_hover(editor.spinBoxCirclePointsQuantity, editor.spinBoxCirclePointsQuantity.value_changed, circle_points_quantity_changed)
	disconnect_action_and_hover(editor.spinBoxLinePointsQuantity, editor.spinBoxLinePointsQuantity.value_changed, line_points_quantity_changed)
	disconnect_action_and_hover(editor.shapeActionButton, editor.shapeActionButton.button_up, apply_changes_to_polygon2D)
	disconnect_action_and_hover(editor.buttonTriangulatePolygons, editor.buttonTriangulatePolygons.pressed, triagulate_polygons)
	disconnect_action_and_hover(editor.optionsShapesVertices, editor.optionsShapesVertices.item_selected, change_shape)
	disconnect_hover(editor.checkInside)
	disconnect_hover(editor.pluginCanvas)
	# save
	disconnect_action(editor.dialogSave.file_selected, save_polygon2d_to_json)
	disconnect_action(editor.dialogLoad.file_selected, load_polygon2d_from_json)
	disconnect_action(editor.buttonSaveToJson.pressed, open_save_editor)
	disconnect_action(editor.buttonLoadFromJson.pressed, open_load_editor)
	# deleting references
	if uvEditorManager && not uvEditorManager.is_queued_for_deletion():
		disconnect_action(uvEditorManager.editorController.canvas_zoom, canvas_zoom)
		disconnect_action(uvEditorManager.editorController.editor_opened, visibility_changed)
		disconnect_action(uvEditorManager.editorController.editor_closed, visibility_changed)
		# mouse
		disconnect_action(uvEditorManager.editorController.mouse_moved, mouse_moved)
		disconnect_action(uvEditorManager.editorController.mouse_moving, mouse_moving)
		disconnect_action(uvEditorManager.editorController.mouse_stopped, mouse_stopped)
		disconnect_action(uvEditorManager.editorController.mouse_button_pressed, mouse_button_pressed)
		disconnect_action(uvEditorManager.editorController.mouse_button_pressing, mouse_button_pressing)
		disconnect_action(uvEditorManager.editorController.mouse_button_released, mouse_button_released)
		uvEditorManager.remove_plugin_from_screen(editor.pluginCanvas)
		uvEditorManager.remove_plugin()

func connect_action(event:Signal, function: Callable):
	if not event.is_connected(function):
		event.connect(function)

func connect_hover(control):
	if not control.mouse_entered.is_connected(mouse_in_controls):
		control.mouse_entered.connect(mouse_in_controls.bind(true, control))
	if not control.mouse_exited.is_connected(mouse_in_controls):
		control.mouse_exited.connect(mouse_in_controls.bind(false, control))

func connect_action_and_hover(control:Control, event:Signal, function: Callable):
	connect_action(event, function)
	connect_hover(control)

func disconnect_action(event:Signal, function: Callable):
	if event.is_connected(function):
		event.disconnect(function)

func disconnect_hover(control):
	if control.mouse_entered.is_connected(mouse_in_controls):
		control.mouse_entered.disconnect(mouse_in_controls)
	if control.mouse_exited.is_connected(mouse_in_controls):
		control.mouse_exited.disconnect(mouse_in_controls)

func disconnect_action_and_hover(control:Control, event:Signal, function: Callable):
	disconnect_action(event, function)
	disconnect_hover(control)

func mouse_in_controls(entered:bool, control):
	if control.name == editor.shapeActionButton.name:
		if entered:
			uvEditorManager.print_feedback("Ready", Color.AQUA)
			isShapeApplyHovered = true
		else:
			uvEditorManager.print_feedback("Not ready", Color.ROSY_BROWN)
			isShapeApplyHovered = false
	else:
		if entered:
			isControllerHovered = true
		else:
			isControllerHovered = false

func mouse_moved(position: Vector2):
	mouse_on_screen = true

func mouse_moving(position: Vector2, velocity: Vector2):
	mouse_on_screen = true
	if mouse_on_screen && mouse_pressed_right:
		mousePositionStopped = uvEditorManager.get_editor_mouse_position(false)
		start_redraw()

func mouse_stopped(position: Vector2):
	mouse_on_screen = false

func mouse_button_pressed(mouseId: int, localGlobal: Vector2, mouseGlobal: Vector2):
	if mouseId == MOUSE_BUTTON_LEFT:
		mouse_pressed_left = true
		if mouse_on_screen:
			mousePositionStopped = uvEditorManager.get_editor_mouse_position(false)
		start_redraw()
	elif mouseId == MOUSE_BUTTON_RIGHT:
		mouse_pressed_right = true
		start_redraw()

func mouse_button_pressing(mouseId: int, localGlobal: Vector2, mouseGlobal: Vector2):
	if mouseId == MOUSE_BUTTON_RIGHT:
		var dummy = 1+1

func mouse_button_released(mouseId: int):
	if mouseId == MOUSE_BUTTON_LEFT:
		mouse_pressed_left = false
		start_redraw()
	elif mouseId == MOUSE_BUTTON_RIGHT:
		mouse_pressed_right = false
		start_redraw()

func visibility_changed(visibility):
	visible = !visible
	if visibility:
		add_vertices_to_shape()
		start_redraw()
	else:
		if shapeVisible:
			editor.addVerticesInShapeButton.text = editor.ADD_VERTICES_IN_SHAPE_BUTTON_TEXT
			editor.vContainerShapeApply.visible = false
			shapeVertices.clear()
			shapeVisible = false

func update_rotation(value: float, caller):
	if not shapeVisible:
		uvEditorManager.print_feedback("Error: Add a shape first", Color.YELLOW)
		return
	if caller is SpinBox:
		editor.hSliderShapeRotation.value = value
		start_redraw()
	if caller is HSlider:
		editor.spinBoxShapeRotation.value = value
		start_redraw()

func layer_quantity_changed(value: float):
	if not shapeVisible:
		uvEditorManager.print_feedback("Error: Add a shape first", Color.YELLOW)
		return
	shapeVertices.clear()
	add_vertices_to_shape()
	start_redraw()

func line_points_quantity_changed(value: int):
	if not shapeVisible:
		uvEditorManager.print_feedback("Error: Add a shape first", Color.YELLOW)
		return
	shapeVertices.clear()
	add_vertices_to_shape()
	start_redraw()

func canvas_zoom(value):
	zoom = value
	if shapeVisible && shapeVertices.size() > 0:
		for point in shapeVertices:
			var xPos:float = (value/16) * (point.x - mousePosition.x) -  uvEditorManager.get_h_scrollbar_value()
			var yPos:float = (value/16) * (point.y - mousePosition.y) - uvEditorManager.get_v_scrollbar_value()
			point.x = xPos
			point.y = yPos
	start_redraw()

func start_redraw():
	if editor.pluginCanvas && not procesingRedraw:
		procesingRedraw = true
		editor.pluginCanvas.queue_redraw()

func process_draw() -> void:
	if procesingRedraw:
		if not isControllerHovered:
			mousePosition = uvEditorManager.get_editor_mouse_position(false)
		procesingRedraw = false
		draw_shapes()

func draw_shapes()->void:
	if not shapeVisible:
		procesingRedraw = false
		return
	if shapeVertices.size() == 0:
		procesingRedraw = false
		return
	var choosenPosition: Vector2 = mousePositionStopped
	var layer: float = editor.spinBoxLayerQuantity.value
	var vertexDistance: float = editor.spinVertexDistance.value
	var maxSideNumber:int = (layer * 2) + 1
	var vertexCount = (BASE_FORM_FACTOR * layer) + 4
	var distanceFactor: float = vertexDistance * layer
	var count:int = 0
	var percentZoom: float = zoom / 16
	var centerVertex:Vector2 = shapeVertices[shapeVertices.size()-1]
	var angle:float = ((editor.spinBoxShapeRotation.value * PI) / 180)
	for vertex in shapeVertices:
		var newX = (vertex.x * cos(angle)) - (vertex.y * sin(angle))
		var newY = (vertex.x * sin(angle)) + (vertex.y * cos(angle))
		var hookX:float = (choosenPosition.x) + newX
		var hookY:float = (choosenPosition.y) + newY
		var xPos:float = hookX
		var yPos:float = hookY
		vertex.x = xPos
		vertex.y = yPos
		var color:Color = Color.WHITE
		var factorCount:float = count/layer/4
		if factorCount >=0 && (factorCount)/4 < 1:
			color = Color.BLUE 
		if factorCount >=1 && (factorCount)/4 < 2:
			color = Color.RED 
		if factorCount >=2 && (factorCount)/4 < 3:
			color = Color.GREEN 
		if factorCount >=3 && (factorCount)/4 < 4:
			color = Color.YELLOW 
		editor.pluginCanvas.draw_circle(vertex, 5, color)
		count = count + 1
	procesingRedraw = false

func create_shape_form_button_click():
	shapeVisible = !shapeVisible
	if !shapeVisible:
		editor.addVerticesInShapeButton.text = editor.ADD_VERTICES_IN_SHAPE_BUTTON_TEXT
		editor.vContainerShapeApply.visible = false
		return
	editor.addVerticesInShapeButton.text = "Cancel"
	editor.vContainerShapeApply.visible = true
	uvEditorManager.print_feedback("", Color.GREEN)
	shapeVertices.clear()
	add_vertices_to_shape()
	start_redraw()
	
func change_shape(selected:int):
	if !shapeVisible:
		return
	shapeVertices.clear()
	add_vertices_to_shape()
	start_redraw()

func add_vertices_to_shape():
	mousePosition = uvEditorManager.get_editor_mouse_position(false)
	var layersCount: int = editor.spinBoxLayerQuantity.value
	var vertexDistance: float = editor.spinVertexDistance.value
	var angle:int = editor.spinBoxCirclePointsQuantity.value
#	var angle:float = ((5 * PI) / 180)
	if editor.optionsShapesVertices.selected == 0:
		editor.hContainerCirclePointsQuantity.visible = true
		editor.hContainerLinePointsQuantity.visible = false
		shapeVertices.append_array(create_circle_vertices_row(vertexDistance, layersCount, angle))
	elif editor.optionsShapesVertices.selected == 1:
		editor.hContainerCirclePointsQuantity.visible = false
		editor.hContainerLinePointsQuantity.visible = false
		for i in layersCount:
			if i == 0:
				shapeVertices.append(Vector2(0,0))
			shapeVertices.append_array(create_square_vertices_row(vertexDistance, i + 1))
	elif editor.optionsShapesVertices.selected == 2:
		editor.hContainerCirclePointsQuantity.visible = false
		editor.hContainerLinePointsQuantity.visible = true
		var posPlus: int = 0
		var posMinus: int = 0
		for i in layersCount:
			var index: int
			if i == 0:
				index = 0
			else:
				var residual: float = i%2
				if residual == 0:
					posPlus += 1
					index = posPlus
				else:
					posMinus -= 1
					index = posMinus
			shapeVertices.append_array(create_line_vertices_row(vertexDistance, index, editor.spinBoxLinePointsQuantity.value))

func create_circle_vertices_row(vertexDistance:float, layers: int, angle: float) ->PackedVector2Array:
	var vertices:PackedVector2Array = []
	vertices.append(Vector2(0, 0))
	for i in layers:
		var vertex:Vector2 = Vector2(vertexDistance*(i+1), vertexDistance*(i+1))
		var count = 360 / angle
		for j in count:
			vertices.append(NeuroArkPolygon2dTools.calculate_rotated_point_2d_degree(vertex, angle, j+1))
	return vertices

func create_square_vertices_row(vertexDistance:float, layer: int) ->PackedVector2Array:
	var vertices:PackedVector2Array = []
	#ths is the max number of vertext a single side of a square should have
	var maxSideNumber:int = (layer * 2) + 1
	var vertexCount = (BASE_FORM_FACTOR * layer) + 4
	var distanceFactor: float = vertexDistance * layer
	var leftToRightSide:int = 0
	var upToDownSide:int = 0
	var rightToLeftSide:int = 0
	var downToUpSide:int = 0
	var actualDistance: int
	var previous:Vector2
	var mouseX:float = 0
	var mouseY:float = 0
	for i in vertexCount:
		var vertex:Vector2
		# Right
		if i < maxSideNumber:
			var posX:float = mouseX + (-distanceFactor + (vertexDistance * leftToRightSide))
			var posY:float = mouseY - distanceFactor
			vertex  = Vector2(posX, posY)
			leftToRightSide = leftToRightSide + 1
		# Down
		elif i >= maxSideNumber && i < maxSideNumber * 2:
			var posX:float = mouseX + distanceFactor
			var posY:float = mouseY + (-distanceFactor + (vertexDistance * upToDownSide))
			vertex  = Vector2(posX, posY)
			upToDownSide = upToDownSide + 1
		# Left
		elif i >= maxSideNumber * 2 && i < maxSideNumber * 3:
			var posX:float = mouseX + (distanceFactor - (vertexDistance * rightToLeftSide))
			var posY:float = mouseY + distanceFactor
			vertex  = Vector2(posX, posY)
			rightToLeftSide = rightToLeftSide + 1
		# Up
		elif i >= maxSideNumber * 3 && i < maxSideNumber * 4:
			var posX:float = mouseX - distanceFactor
			var posY:float = mouseY - (-distanceFactor + (vertexDistance * downToUpSide))
			vertex  = Vector2(posX, posY)
			downToUpSide = downToUpSide + 1
		if vertex:
			var found:bool = false
			for vertice in vertices:
				if vertex.x == vertice.x && vertex.y == vertice.y:
					found = true
			if not found:
				vertices.append(vertex)
			previous = vertex
	return vertices

func create_line_vertices_row(vertexDistance:float, layer: int, vertexCount: int) ->PackedVector2Array:
	var vertices:PackedVector2Array = []
	var mouseX:float = 0
	var mouseY:float = 0
	for i in vertexCount:
		var posX:float = vertexDistance * i
		var posY:float = vertexDistance * layer
		var vertex:Vector2 = Vector2(posX, posY)
		vertices.append(vertex)
	return vertices

func vertex_distance_changed(value:float):
	if not shapeVisible:
		uvEditorManager.print_feedback("Error: Add a shape first", Color.YELLOW)
		return
	shapeVertices.clear()
	add_vertices_to_shape()
	start_redraw()

func circle_points_quantity_changed(value:float):
	if not shapeVisible:
		uvEditorManager.print_feedback("Error: Add a shape first", Color.YELLOW)
		return
	shapeVertices.clear()
	add_vertices_to_shape()
	start_redraw()

func apply_changes_to_polygon2D():
	if not shapeVisible:
		uvEditorManager.print_feedback("Error: Add a shape first", Color.YELLOW)
		return
	if not uvEditorManager.validate_polygon2d():
		uvEditorManager.print_feedback("Error: Polygon 2d not found. \n Please, reselect the Polygon 2d in the editor  \n or synchronize the bones", Color.RED)
		return
	if not uvEditorManager.get_polygon_2d().polygon.size()>3:
		uvEditorManager.print_feedback("Error: Polygon must have at least 3 vertices.\nPlease, add them", Color.RED)
		return
	var tempPoly: PackedVector2Array
	for vertex in uvEditorManager.get_polygon_2d().polygon:
		tempPoly.append(vertex)
	var tempUV: PackedVector2Array
	for vertex in uvEditorManager.get_polygon_2d().uv:
		tempUV.append(vertex)
	var layer: float = editor.spinBoxLayerQuantity.value
	var vertexDistance: float = editor.spinVertexDistance.value
	var maxSideNumber: int = (layer * 2) + 1
	var zoomPercent: float
	if Engine.get_version_info().hex < NeuroArkUVEditorView.GODOT_VER_4_3:
		zoomPercent = zoom / 16
	else:
		zoomPercent = zoom / 128
	var angle:float = ((editor.spinBoxShapeRotation.value * PI) / 180)
	var distantFactor:float = vertexDistance * maxSideNumber
	var parentSize:Vector2 = editor.pluginCanvas.get_parent_area_size()
	var scrollBarX:float  = uvEditorManager.get_h_scrollbar_value()
	var scrollBarY:float  = uvEditorManager.get_v_scrollbar_value()
	var addedCount: int = 0
	for vertex in shapeVertices:
		var newX = (vertex.x * cos(angle)) - (vertex.y * sin(angle))
		var newY = (vertex.x * sin(angle)) + (vertex.y * cos(angle))
		var xPos:float = (mousePositionStopped.x) + newX
		var yPos:float = (mousePositionStopped.y) + newY
		var offsetX:float #This will compensate the scroll bar x
		var offsetY:float #This will compensate the scroll bar y
		if Engine.get_version_info().hex < NeuroArkUVEditorView.GODOT_VER_4_3:
			offsetX = scrollBarX
			offsetY = scrollBarY
		else:
			offsetX = scrollBarX * zoom
			offsetY = scrollBarY * zoom
		vertex.x = (xPos + offsetX) / zoom
		vertex.y = (yPos + offsetY) / zoom
		if editor.checkInside.button_pressed:
			if Geometry2D.is_point_in_polygon(vertex, uvEditorManager.get_polygon_2d().polygon):
				tempPoly.append(vertex)
				tempUV.append(vertex)
				addedCount = addedCount + 1
		else: 
			tempPoly.append(vertex)
			tempUV.append(vertex)
			addedCount = addedCount + 1
	uvEditorManager.get_polygon_2d().internal_vertex_count = uvEditorManager.get_polygon_2d().internal_vertex_count + addedCount
	uvEditorManager.get_polygon_2d().polygon = tempPoly
	uvEditorManager.get_polygon_2d().uv  = tempUV
	#This will set the bone weights in order to avoid errors
	uvEditorManager.editorController.update_bone_weights()
	uvEditorManager.get_polygon_2d().queue_redraw()
	shapeVertices.clear()
	uvEditorManager.print_feedback("Changes applied", Color.GREEN)
	editor.vContainerShapeApply.visible = false
	editor.addVerticesInShapeButton.text = editor.ADD_VERTICES_IN_SHAPE_BUTTON_TEXT
	shapeVisible = false
	uvEditorManager.vertices_count_updated()
	start_redraw()

func triagulate_polygons():
	if NeuroArkPolygon2dTools.triangulate_polygons(uvEditorManager.get_polygon_2d()):
		uvEditorManager.redraw_editor()

func save_polygon2d_to_json(filePath:String):
	var result: bool = NeuroArkSavePolygon2dTools.save_polygon_data_on_disk(uvEditorManager.get_polygon_2d(), filePath)
	if result:
		uvEditorManager.print_feedback("The JSON file was created successfully", Color.GREEN)
		return 
	uvEditorManager.print_feedback("Error: The JSON file was not created", Color.RED)
	
func load_polygon2d_from_json(filePath:String):
	var result:Polygon2D = NeuroArkSavePolygon2dTools.load_polygon_data_from_disk(filePath)
	if not NeuroArkSavePolygon2dTools.polygon_2d_has_data(result):
		uvEditorManager.print_feedback("Error: The JSON file was not loaded", Color.RED)
		return
	# In the case the bones of the current polygond2d is different from the bones on the loaded data
	if uvEditorManager.get_polygon_2d().get_bone_count() != result.get_bone_count():
		uvEditorManager.get_button_synchronization().pressed.emit()
	uvEditorManager.get_polygon_2d().uv = result.uv
	uvEditorManager.get_polygon_2d().polygon = result.polygon
	uvEditorManager.get_polygon_2d().polygons = result.polygons
	uvEditorManager.get_polygon_2d().internal_vertex_count = result.internal_vertex_count
	var boneCount:int = result.get_bone_count()
	for i in range(0, boneCount, 1):
		uvEditorManager.get_polygon_2d().set_bone_path(i, result.get_bone_path(i))
		uvEditorManager.get_polygon_2d().set_bone_weights(i, result.get_bone_weights(i))
	uvEditorManager.print_feedback("The JSON file was loaded successfully", Color.GREEN)

func open_save_editor():
	editor.dialogSave.visible = true

func open_load_editor():
	editor.dialogLoad.visible = true
