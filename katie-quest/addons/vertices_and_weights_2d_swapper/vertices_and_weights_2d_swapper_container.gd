@tool
extends VBoxContainer

var polygon2d : Polygon2D = null
var bonesContainerCopy: VBoxContainer = null
var bonesContainerPaste: VBoxContainer = null
var buttonGroupCopy: ButtonGroup = null
var buttonGroupPaste: ButtonGroup = null
var labelCount: Label = null
var labelLastOperation: Label = null

signal refresh_screen

func _ready():
	$ScrollContainerBones/VBoxContainerBones/HBoxContainerControls/ButtonSwapVerticesH.connect("pressed", swap_vertices_h)
	$ScrollContainerBones/VBoxContainerBones/HBoxContainerControls/ButtonSwapVerticesV.connect("pressed", swap_vertices_v)
	$ScrollContainerBones/VBoxContainerBones/ButtonSwapWeights.connect("pressed", swap_weights)
	$ScrollContainerBones/VBoxContainerBones/ButtonCopyWeights.connect("pressed", copy_weights)
	$ScrollContainerBones/VBoxContainerBones/ButtonMoveWeights.connect("pressed", move_weights)
	bonesContainerCopy = $ScrollContainerBones/VBoxContainerBones/HBoxContainerWeights/VBoxContainerBonesCopy
	bonesContainerPaste = $ScrollContainerBones/VBoxContainerBones/HBoxContainerWeights/VBoxContainerBonesPaste
	labelCount = $ScrollContainerBones/VBoxContainerBones/HBoxContainerBonesTitle/LabelTotalBonesNumber
	labelLastOperation = $ScrollContainerBones/VBoxContainerBones/LabelLastOperation

func swap_vertices_h():
	if polygon2d:
		polygon2d.polygon = NeuroArkSwapper2DTools.swap_vertices_h(polygon2d.polygon)
		polygon2d.uv = NeuroArkSwapper2DTools.swap_vertices_h(polygon2d.uv)
		refresh_screen.emit()
		labelLastOperation.text = "Last operation: Swapped vertices horizontally"
	else :
		labelLastOperation.text = "Error: polygon2d null"

func swap_vertices_v():
	if polygon2d:
		polygon2d.polygon = NeuroArkSwapper2DTools.swap_vertices_v(polygon2d.polygon)
		polygon2d.uv = NeuroArkSwapper2DTools.swap_vertices_v(polygon2d.uv)
		refresh_screen.emit()
		labelLastOperation.text = "Last operation: Swapped vertices vertically"		
	else :
		labelLastOperation.text = "Error: polygon2d null"

func swap_weights():
	var copyIndex: int = find_pressed_button(buttonGroupCopy.get_buttons())
	var pasteIndex: int = find_pressed_button(buttonGroupPaste.get_buttons())
	if copyIndex != -1 && pasteIndex != -1:
		var copiedWeights1: PackedFloat32Array = polygon2d.get_bone_weights(copyIndex)
		var copiedWeights2: PackedFloat32Array = polygon2d.get_bone_weights(pasteIndex)
		polygon2d.set_bone_weights(copyIndex, copiedWeights2)
		polygon2d.set_bone_weights(pasteIndex, copiedWeights1)
		reset_buttons()
		refresh_screen.emit()
		var boneFrom: String = buttonGroupCopy.get_buttons()[copyIndex].text
		var boneTo: String = buttonGroupPaste.get_buttons()[pasteIndex].text
		labelLastOperation.text = "Last operation: Swapped weights from " + boneFrom + " to " + boneTo
	else :
		labelLastOperation.text = "Select both bones first"
		
func copy_weights():
	var copyIndex: int = find_pressed_button(buttonGroupCopy.get_buttons())
	var pasteIndex: int = find_pressed_button(buttonGroupPaste.get_buttons())
	if copyIndex != -1 && pasteIndex != -1:
		var copiedWeights: PackedFloat32Array = polygon2d.get_bone_weights(copyIndex)
		polygon2d.set_bone_weights(pasteIndex, copiedWeights)
		reset_buttons()
		refresh_screen.emit()
		var boneFrom: String = buttonGroupCopy.get_buttons()[copyIndex].text
		var boneTo: String = buttonGroupPaste.get_buttons()[pasteIndex].text		
		labelLastOperation.text = "Last operation: Copied weights from " + boneFrom + " to " + boneTo
	else :
		labelLastOperation.text = "Select both bones first"

func move_weights():
	var copyIndex: int = find_pressed_button(buttonGroupCopy.get_buttons())
	var pasteIndex: int = find_pressed_button(buttonGroupPaste.get_buttons())
	if copyIndex != -1 && pasteIndex != -1:
		var copiedWeights: PackedFloat32Array = polygon2d.get_bone_weights(copyIndex)
		polygon2d.set_bone_weights(pasteIndex, copiedWeights)
		polygon2d.set_bone_weights(copyIndex, NeuroArkSwapper2DTools.copy_and_fill_int32Array(copiedWeights, 0))
		reset_buttons()
		refresh_screen.emit()
		var boneFrom: String = buttonGroupCopy.get_buttons()[copyIndex].text
		var boneTo: String = buttonGroupPaste.get_buttons()[pasteIndex].text
		labelLastOperation.text = "Last operation: Moved weights from " + boneFrom + " to " + boneTo
	else :
		labelLastOperation.text = "Select both bones first"

func find_pressed_button(buttons: Array[BaseButton])->int:
	var count: int = 0
	var foundIndex: int = -1
	for button: CheckButton in buttons:
		if button.is_pressed():
			foundIndex = count
			break
		count = count+1
	return foundIndex

func fill_bone_containers():
	if polygon2d:
		var boneCount: int = polygon2d.get_bone_count()
		#If the group has already been created
		if buttonGroupCopy:
			var buttonCopyCount: int = buttonGroupCopy.get_buttons().size()
			#we proceed to check if the group size corresponds to the bone list size.
			if buttonCopyCount != boneCount:
				#if not, we proceed to remove all buttons and recreate them all again
				NeuroArkNodeTools.remove_all_child_from_type(bonesContainerCopy, "CheckButton")
				buttonGroupCopy = ButtonGroup.new()
				createBonesButtons(buttonGroupCopy, bonesContainerCopy)
#				print("Recreating the button copy group: "+str(buttonCopyCount) + "=" + str(boneCount))
		#The group has not been created, so we proceed to create a new one
		else :
			if bonesContainerCopy && bonesContainerCopy.get_children(true).size() <= 1 :
				buttonGroupCopy = ButtonGroup.new()
				createBonesButtons(buttonGroupCopy, bonesContainerCopy)
		#If the group has already been created
		if buttonGroupPaste:
			var buttonPasteCount: int = buttonGroupPaste.get_buttons().size()
			#we proceed to check if the group size corresponds to the bone list size.
			if buttonPasteCount != boneCount:
				#if not, we proceed to remove all buttons and recreate them all again
				NeuroArkNodeTools.remove_all_child_from_type(bonesContainerPaste, "CheckButton")
				buttonGroupPaste = ButtonGroup.new()
				createBonesButtons(buttonGroupPaste, bonesContainerPaste)
		#The group has not been created, so we proceed to create a new one
		else :
			if bonesContainerPaste && bonesContainerPaste.get_children(true).size() <= 1 :
				buttonGroupPaste = ButtonGroup.new()
				createBonesButtons(buttonGroupPaste, bonesContainerPaste)
		if labelCount:
			labelCount.text = str(polygon2d.bones.size())

func reset_buttons():
	if buttonGroupCopy:
		var button: BaseButton = buttonGroupCopy.get_pressed_button()
		if button:
			button.set_pressed(false)
	if buttonGroupPaste:
		var button: BaseButton = buttonGroupPaste.get_pressed_button()
		if button:
			button.set_pressed(false)

func createBonesButtons(buttonGroup: ButtonGroup, bonesContainer: VBoxContainer):
	for bone in polygon2d.bones:
		if bone is String :
			var optionButton: CheckButton = createBoneButton(bone, buttonGroup)
			bonesContainer.add_child(optionButton)

func createBoneButton(bone: String, group: ButtonGroup)-> CheckButton:
	var button: CheckButton = CheckButton.new()
	button.toggle_mode = true
	button.text = bone.get_file()
	button.button_group = group
	return button
