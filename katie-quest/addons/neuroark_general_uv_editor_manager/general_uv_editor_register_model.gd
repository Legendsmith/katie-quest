@tool
class_name  NeuroArkGeneralUVEditorRegisterModel
var editorID: String
var positioned: bool
var openCounter: int

func _init(_editorID: String, _positioned: bool):
	editorID = _editorID
	positioned = _positioned
	openCounter = 0
