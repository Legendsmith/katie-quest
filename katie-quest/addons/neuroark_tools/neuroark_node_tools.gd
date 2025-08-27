@tool
extends Node
class_name NeuroArkNodeTools


static func get_godot_editor_version()->String:
	var version_info = Engine.get_version_info()
	return version_info["major"] + "." + version_info["minor"] + "." +version_info["patch"]	

## Structure printers
static func print_godot_structure():
	var count = 0
	for child in EditorInterface.get_base_control().get_children(false):
		print("_______________________________ " + str(count) + " _ " + child.name  + " _ " + child.get_class() + " _______________________________")
		print_node_structure(child, false)
		count = count + 1
		print("__________________________________________________________________")

static func print_godot_structure_direct(fileName:String, version:String):
	print("1.. storing godot strucute on text file estructura.txt")
	var editor = EditorInterface.get_base_control().get_children(true)
	var txt = ""
	print("2.. childs retrieved")
	for child in editor:
		txt = txt + child.get_tree_string_pretty()
	print("3.. Saving...")
	NeuroArkFileTools.save_string_to_disk(txt, fileName + "_" + version)
	print("4.. Finished...")

static func print_editor_structure():
	var count = 0
	for child in EditorInterface.get_base_control().find_children("*", "Polygon2DEditor", true, false):
		print("_______________________________ " + str(count) + " _ " + child.name + " _______________________________")
		var childControls = child.find_children("*","Control", true, false)
		if(childControls):
			print_nodes_structures(childControls)
		count = count + 1
		print("__________________________________________________________________")

static func print_nodes_structures(nodes: Array[Node]):
	for node in nodes:
		print_node_structure(node, false)

static func print_node_structure(node: Node, printParentSequence: bool):
	var txt = node.get_tree_string_pretty()
	if printParentSequence :
		var parent = node.get_parent()
		var count = 0
		while parent :
			print("Parent lvl " + str(count) + ": [" + parent.get_class() + " : " + str(parent.unique_name_in_owner) + " = " + parent.name + "]")
			parent = parent.get_parent()
			count = count + 1
	print(node.get_class() + " : " + str(node.unique_name_in_owner) + " = " + node.name + " => ")
	print(txt)

static func print_unknow_node_data(node:Node):
	print ("{'class':" + node.get_class() + ", \n{'signals':\n" + str(node.get_signal_list())+ ", \n'methods':\n" + str(node.get_method_list()) + ", \n'properties':\n" + str(node.get_property_list())+"}")

## Debug helpers
static func print_debug_message(functionName:String, message:String, debug: bool = false):
	var msg:String = functionName + ":\n" + message
	if debug:
		printerr(msg)
		push_warning(msg)
	else:
		printerr(msg)

static func combine_paths(absolute:NodePath, relative:NodePath)-> NodePath:
	var count:int = 0
	for i in relative.get_name_count():
		if relative.get_name(i) == "..":
			count+=1
	var name:String = relative.get_name(relative.get_name_count() - 1)
	var path: Array[String]
	for i in absolute.get_name_count() - count:
		path.append(absolute.get_name(i))
	path.append(name)
	var stringPath: String = ""
	for i in path.size():
		if i == 0:
			stringPath = path[i]
		else:
			stringPath += "/" + path[i]
	return NodePath(stringPath)

static func remove_from_path(remove:NodePath, from:NodePath) -> NodePath:
	var toRemove:String = remove.get_concatenated_names()
	var fromRemove:String = from.get_concatenated_names()
	if fromRemove.contains(toRemove):
		var index:int = fromRemove.find(toRemove) + toRemove.length()
		return NodePath(fromRemove.substr(index))
	return from

## Object finders
static func find_child_with_label(object: Node, type: String, label: String, recursive: bool)->Node:
	var children = object.find_children("*", type, recursive, false)
	for child in children:
		print("type:"+type+", label:"+label)
		if child.text == label:
			return child
	return null

## Remove nodes
static func remove_all_child_from_type(node: Node, type: String, delete:bool = true):
	var children = node.find_children("*", type, true, false)
	for child in children:
		node.remove_child(child)
		if delete:
			child.queue_free()

static func remove_all_childs_from_node(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

static func add_child_to_parent(node: Node, parent: Node)->String:
	if not node || not parent:
		return "Node or parent not valid"
	if node.get_parent():
		return "This node has already a parent:"+str(node.get_parent().name)
	parent.add_child(node)
	return ""

static func remove_child_from_parent(node: Node, parent: Node)->String:
	if not node || not parent:
		return "Node or parent not valid"
	if not node.is_ancestor_of(parent):
		return "The node " + str(node.name) + "is not children of " + str(parent.name)
	parent.remove_child(node)
	return ""

static func has_function_attached(sig: Signal, name: String)->bool:
	var connections = sig.get_connections()
	for connection in connections:
		var object = connection["callable"].get_object()
		var method = connection["callable"].get_method()
		if name == method:
			return true
	return false

static func attach_and_reparent_control(newNode:Control, hookNode:Control, newContainer:Control, first:bool):
	var actualParent = hookNode.get_parent()
	var index:int = hookNode.get_index()
	if first:
		newContainer.add_child(newNode)
		hookNode.reparent(newContainer)
	else:
		hookNode.reparent(newContainer)
		newContainer.add_child(newNode)
	actualParent.add_child(newContainer)
	actualParent.move_child(newContainer, index)
