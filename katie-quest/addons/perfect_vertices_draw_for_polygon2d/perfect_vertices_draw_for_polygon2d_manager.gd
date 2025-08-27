@tool
extends EditorPlugin
class_name PerfectVerticesForPolygon2DManager

const EDITOR = "PerfectVerticesForPolygon2DManager"

var editorView: PerfectVerticesForPolygon2DView = null
var editorController: PerfectVerticesForPolygon2DController = null

func initialize_plugin(pluginEditorManager: NeuroArkGeneralUVEditorManager, offset:float):
	editorView = PerfectVerticesForPolygon2DView.new()
	editorController = PerfectVerticesForPolygon2DController.new(pluginEditorManager, editorView)
	editorView.initialize_plugin(pluginEditorManager, offset)
	editorController.initialize_listeners()
	editorView.initialize_default_data()

func remove_plugin():
	editorController.close_listeners()
	editorView.remove_plugin()
