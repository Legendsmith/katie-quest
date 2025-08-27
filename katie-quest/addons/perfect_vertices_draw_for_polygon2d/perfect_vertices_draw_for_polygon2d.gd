@tool
extends EditorPlugin
# Editor panel controls
var pluginEditorManager: NeuroArkGeneralUVEditorManager = null
var pluginManager: PerfectVerticesForPolygon2DManager = null
func _enter_tree():
	if not Engine.has_singleton(NeuroArkGeneralUVEditorManager.SINGLETON_NAME):
		add_autoload_singleton(NeuroArkGeneralUVEditorManager.SINGLETON_NAME, "res://addons/neuroark_general_uv_editor_manager/general_uv_editor_manager.gd")
	pluginEditorManager = get_node("/root/" + NeuroArkGeneralUVEditorManager.SINGLETON_NAME)
	var offset:float = 40
	if EditorInterface.is_plugin_enabled("precise_bone_weights_manager_for_polygon2d"):
		offset = 260
	pluginManager = PerfectVerticesForPolygon2DManager.new()
	pluginManager.initialize_plugin(pluginEditorManager, offset)
	pluginEditorManager.register_editor(NeuroArkGeneralUVEditorRegisterModel.new(PerfectVerticesForPolygon2DManager.EDITOR, false))

func _exit_tree():
	if pluginManager && not pluginManager.is_queued_for_deletion():
		pluginManager.remove_plugin()
		pluginManager.queue_free()
	if pluginEditorManager && not pluginEditorManager.is_queued_for_deletion():
		pluginEditorManager.queue_free()
	pluginEditorManager.unregister_editor(PerfectVerticesForPolygon2DManager.EDITOR)
	if pluginEditorManager.activePlugins.size() == 0:
		remove_autoload_singleton(NeuroArkGeneralUVEditorManager.SINGLETON_NAME)


func _has_main_screen():
	return false

func _handles(object: Object) -> bool:
	if object is Polygon2D:
		pluginEditorManager.editorView.polygon2D = object
		pluginEditorManager.validate_radio_buttons(false)
		pluginManager.editorController.start_redraw()
		return false
	return false
