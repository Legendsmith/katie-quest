@tool
extends Node2D
class_name PerfectVerticesForPolygon2DView
const SHAPES: Array[String] = ["Circle", "Square", "Line"]
const SHAPE_CIRCLE: int = 0
const SHAPE_SQUARE: int = 1
const SHAPE_LINE: int = 2
const ADD_VERTICES_IN_SHAPE_BUTTON_TEXT:String = "Create shape"
const CANVAS_NAME: String = "neuroark_section_uv_editor"
# Editor panel controls
var pluginCanvas: VBoxContainer = null
# Shapes
var vContainerShapeControls: VBoxContainer = null
var vContainerShapeApply: VBoxContainer = null
var hContainerCirclePointsQuantity: HBoxContainer = null
var hContainerLinePointsQuantity: HBoxContainer = null
var optionsShapesVertices: OptionButton = null
var spinVertexDistance: SpinBox = null
var spinBoxLayerQuantity: SpinBox = null
var spinBoxShapeRotation:SpinBox = null
var spinBoxCirclePointsQuantity: SpinBox = null
var spinBoxLinePointsQuantity: SpinBox = null
var hSliderShapeRotation: HSlider = null
var addVerticesInShapeButton: Button = null
var shapeActionButton: Button = null
var buttonTriangulatePolygons: Button = null
var buttonSaveToJson: Button = null
var buttonLoadFromJson: Button = null
var checkInside: CheckBox = null
var vContainerPerfectVertices2D: VBoxContainer
var vContainterMain: VBoxContainer = null
var uvEditorManager:NeuroArkGeneralUVEditorManager
var labelFeedback: Label = null
var labelShapesTitle: Label = null
var dialogLoad:FileDialog = null
var dialogSave:FileDialog = null

func initialize_plugin(editorManager:NeuroArkGeneralUVEditorManager, offset:float):
	if editorManager:
		uvEditorManager = editorManager
		uvEditorManager.initialize_plugin()
	else:
		uvEditorManager = NeuroArkGeneralUVEditorManager.new()
		uvEditorManager.initialize_plugin()
	pluginCanvas = create_canvas(offset)
	if not pluginCanvas:
		editorManager.print_feedback("Error: Plugin canvas is null", Color.RED)
		return
	uvEditorManager.add_plugin_to_screen(pluginCanvas)


func remove_plugin():
	if uvEditorManager:
		uvEditorManager.remove_child_from_neuroark_scroll_widget_in_bones_radios_section(vContainterMain, true)
		uvEditorManager.remove_plugin_from_screen(pluginCanvas)
		uvEditorManager.remove_plugin()
	if pluginCanvas && not pluginCanvas.is_queued_for_deletion():
		pluginCanvas.queue_free()	

	
func create_canvas(offset:float) -> VBoxContainer:
	if not uvEditorManager || not uvEditorManager.get_editor(): return
	var path: NodePath = uvEditorManager.get_editor().get_path()
	var canvasPath: NodePath = NodePath(path.get_concatenated_names()+"/"+CANVAS_NAME)
	var vContainerPerfectVertices2DPath: NodePath = NodePath(path.get_concatenated_names() + "/" + CANVAS_NAME  + "/" + "NeuroArkUVEditorContainer" + "/" + "VContainerPerfectVertices2D")
	var vContainerPerfectVertices2D = get_node(vContainerPerfectVertices2DPath)
	if vContainerPerfectVertices2D:
		return vContainerPerfectVertices2D
	vContainerPerfectVertices2D = uvEditorManager.get_plugin_container()
	# Shapes references
	vContainerShapeControls = VBoxContainer.new()
	labelShapesTitle = NeuroArkUITools.create_a_label("Perfect vertices", HORIZONTAL_ALIGNMENT_CENTER)
	optionsShapesVertices = OptionButton.new()
	var hContainerVertexQuantity: HBoxContainer = HBoxContainer.new()
	spinBoxLayerQuantity =  NeuroArkUITools.create_a_spinbox(1, 1, 1, 30)
	var labelVertexQuantity:Label =  NeuroArkUITools.create_a_label("Rows quantity: ", HORIZONTAL_ALIGNMENT_CENTER)
	var hContainerVertexDistance: HBoxContainer = HBoxContainer.new()
	spinVertexDistance =  NeuroArkUITools.create_a_spinbox(30, 5, 5, 1000)
	var labelDistance:Label =  NeuroArkUITools.create_a_label("Distance: ", HORIZONTAL_ALIGNMENT_CENTER)
	addVerticesInShapeButton =  NeuroArkUITools.create_a_button(ADD_VERTICES_IN_SHAPE_BUTTON_TEXT, HORIZONTAL_ALIGNMENT_CENTER, Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_CENTER, true)
	vContainerShapeApply = VBoxContainer.new()
	var vContainterExtraControls: VBoxContainer = VBoxContainer.new()
	var vContainerShapeRotation: VBoxContainer = VBoxContainer.new()
	var hContainerShapeRotation: HBoxContainer = HBoxContainer.new()
	var labelShapeRotation:Label =  NeuroArkUITools.create_a_label("Rotate shape angle: ", HORIZONTAL_ALIGNMENT_CENTER)
	spinBoxShapeRotation =  NeuroArkUITools.create_a_spinbox(0, 1, -359, 360)
	hSliderShapeRotation =  NeuroArkUITools.create_a_hslider(0, 1, -359, 360)
	hContainerCirclePointsQuantity = HBoxContainer.new()
	spinBoxCirclePointsQuantity =  NeuroArkUITools.create_a_spinbox(45, 15, 15, 180)
	var labelCirclePointsQuantity =  NeuroArkUITools.create_a_label("Circle points quantity: ", HORIZONTAL_ALIGNMENT_CENTER)
	hContainerLinePointsQuantity = HBoxContainer.new()
	var labelLineQuantity:Label =  NeuroArkUITools.create_a_label("Line points quantity: ", HORIZONTAL_ALIGNMENT_CENTER)
	spinBoxLinePointsQuantity =  NeuroArkUITools.create_a_spinbox(0, 1, 1, 300)
	shapeActionButton =  NeuroArkUITools.create_a_button("Apply", HORIZONTAL_ALIGNMENT_CENTER, Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_CENTER, true)
	buttonTriangulatePolygons = NeuroArkUITools.create_a_button("Create / Update Polygons 2D", HORIZONTAL_ALIGNMENT_CENTER, Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_CENTER, true)
	var hContainerSaveLoad: HBoxContainer = HBoxContainer.new()
	buttonSaveToJson =  NeuroArkUITools.create_a_button("Save polygon 2d data to JSON", HORIZONTAL_ALIGNMENT_CENTER, Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_CENTER, true)
	buttonLoadFromJson =  NeuroArkUITools.create_a_button("Load polygon 2d data from JSON", HORIZONTAL_ALIGNMENT_CENTER, Control.SIZE_EXPAND_FILL, Control.SIZE_SHRINK_CENTER, true)
	dialogLoad = NeuroArkUITools.create_file_dialog("*.json", "Json file with polygon 2d data to load", false, false, false, false)
	dialogSave = NeuroArkUITools.create_file_dialog("*.json", "Json file with polygon 2d data to save", false, false, false, true)
	labelFeedback = Label.new()
	checkInside = CheckBox.new()
	vContainterMain = VBoxContainer.new()
	# Create hierarchy #
	hContainerVertexQuantity.add_child(labelVertexQuantity)
	hContainerVertexQuantity.add_child(spinBoxLayerQuantity)
	hContainerVertexDistance.add_child(labelDistance)
	hContainerVertexDistance.add_child(spinVertexDistance)
	hContainerCirclePointsQuantity.add_child(labelCirclePointsQuantity)
	hContainerCirclePointsQuantity.add_child(spinBoxCirclePointsQuantity)
	vContainerShapeControls.add_child(labelShapesTitle)
	vContainerShapeControls.add_child(optionsShapesVertices)
	vContainerShapeControls.add_child(hContainerVertexQuantity)
	vContainerShapeControls.add_child(hContainerVertexDistance)
	vContainerShapeControls.add_child(addVerticesInShapeButton)
	hContainerShapeRotation.add_child(labelShapeRotation)
	hContainerShapeRotation.add_child(spinBoxShapeRotation)
	vContainerShapeRotation.add_child(hContainerShapeRotation)
	vContainerShapeRotation.add_child(hSliderShapeRotation)
	hContainerLinePointsQuantity.add_child(labelLineQuantity)
	hContainerLinePointsQuantity.add_child(spinBoxLinePointsQuantity)
	vContainterExtraControls.add_child(vContainerShapeRotation)
	vContainterExtraControls.add_child(hContainerCirclePointsQuantity)
	vContainterExtraControls.add_child(hContainerLinePointsQuantity)
	vContainterExtraControls.add_child(checkInside)
	vContainerShapeApply.add_child(vContainterExtraControls)
	vContainerShapeApply.add_child(shapeActionButton)
	hContainerSaveLoad.add_child(buttonSaveToJson)
	hContainerSaveLoad.add_child(buttonLoadFromJson)
	hContainerSaveLoad.add_child(dialogLoad)
	hContainerSaveLoad.add_child(dialogSave)
		# Controls Section
	vContainterMain.add_child(vContainerShapeControls)
	vContainterMain.add_child(vContainerShapeApply)
	vContainterMain.add_child(buttonTriangulatePolygons)
	vContainterMain.add_child(hContainerSaveLoad)
	vContainterMain.add_child(labelFeedback)
		# Add all to the canvas
	uvEditorManager.add_child_to_neuroark_scroll_widget_in_bones_radios_section(vContainterMain, true)
#	vContainerPerfectVertices2D.add_child(vContainterMain)
	return vContainerPerfectVertices2D

func initialize_default_data():
	checkInside.text = "Inside Polygon (experimental)"
	# Shapes presets
	labelShapesTitle.modulate = uvEditorManager.get_title_color()
	for shape in SHAPES:
		optionsShapesVertices.add_item(shape)
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color(Color(0, 0, 0, 0.3))
	uvEditorManager.get_editor().add_theme_stylebox_override("panel", new_style)
	# Controls sub section
	vContainerShapeApply.visible = false
