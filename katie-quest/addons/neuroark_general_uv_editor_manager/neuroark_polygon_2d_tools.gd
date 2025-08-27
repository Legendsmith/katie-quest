@tool
extends Node2D
class_name NeuroArkPolygon2dTools

const INVALID_INDEX: int = -1
const LIMIT_START_INDEX:int = 0
const LIMIT_END_INDEX:int = 1
const LIMIT_CEIL_INDEX:int = 2
const LIMIT_FLOOR_INDEX:int = 3
const LIMIT_WIDTH_INDEX:int = 4
const LIMIT_HEIGHT_INDEX:int = 5
const BOX_UPPER_RIGHT_INDEX:int = 0
const BOX_UPPER_LEFT_INDEX:int = 1
const BOX_LOWER_LEFT_INDEX:int = 2
const BOX_LOWER_RIGHT_INDEX:int = 3
const BOX_WIDTH_INDEX:int = 4
const BOX_HEIGHT_INDEX:int = 5
static func get_all_bone_weights(polygon2d: Polygon2D, printInfo:bool = false) -> Array[PackedFloat32Array]:
	# Weight
	var weightsCopy: Array[PackedFloat32Array]
	var boneCount:int = polygon2d.get_bone_count()
		# Passing throught all bones
	for bone in boneCount:
		if printInfo:
			print("bone:"+str(bone)+", from count:"+str(boneCount))
		var actualWeights: PackedFloat32Array = polygon2d.get_bone_weights(bone)
		weightsCopy.append(actualWeights)
	return weightsCopy

static func find_bone_index_in_polygon_2d(bone:Bone2D, polygon:Polygon2D)-> int:
	var polyBoneCount: int = polygon.get_bone_count()
	for i in polyBoneCount:
		var polyPath: NodePath = polygon.get_bone_path(i)
		var bonePath: NodePath = bone.get_path()
		var polyName:StringName = polyPath.get_name(polyPath.get_name_count() - 1)
		var boneName:StringName = bonePath.get_name(bonePath.get_name_count() - 1)
		if polyName == boneName:
			return i
	return INVALID_INDEX

static func find_bone_index_in_skeleton_2d(bonePath:NodePath, skeleton:Skeleton2D)-> int:
	var skeleBoneCount: int = skeleton.get_bone_count()
	for i in skeleBoneCount:
		var skelePath: NodePath = skeleton.get_bone(i).get_path()
		var skeleName:StringName = skelePath.get_name(skelePath.get_name_count()-1)
		var boneName:StringName = bonePath.get_name(bonePath.get_name_count() -1)
		if skeleName == boneName:
			return i
	return INVALID_INDEX

static func resynchronize_bones(polygon2d: Polygon2D, printInfo:bool = false)->String:
	var msg:String = ""
	if not polygon2d.skeleton:
		msg = "There is no skeleton attached to this polygon"
		if printInfo:
			print(msg)
		return msg
	var nodePath: NodePath = EditorInterface.get_edited_scene_root().get_path_to(polygon2d)
	var skelPath: NodePath = NeuroArkNodeTools.combine_paths(nodePath, polygon2d.skeleton)
	var skeleton: Skeleton2D = EditorInterface.get_edited_scene_root().get_node(skelPath)
	msg = "Skeleton path:" + skelPath.get_concatenated_names()
	if printInfo:
		print(msg)
	if skeleton == null:
		msg = "The skeleton doesn't exist in this scene"
		if printInfo:
			print(msg)
		return msg
	var isSkeleton2d: bool = skeleton is Skeleton2D
	if not isSkeleton2d:
		msg = "The attached skeleton is not valid"
		if printInfo:
			print(msg)
		return msg
	var skeleBoneCount:int = skeleton.get_bone_count()
	var polyBoneCount: int = polygon2d.get_bone_count()
	var tempPolygons:PackedVector2Array = polygon2d.polygon
	var bonesToProcess: Array[int]
	# Clean polygon paths with extra badage
	for i in polyBoneCount:
		if printInfo:
			print("Actual BonePath: "+polygon2d.get_bone_path(i).get_concatenated_names())
		var path =  NeuroArkNodeTools.remove_from_path(skelPath, polygon2d.get_bone_path(i))
		polygon2d.set_bone_path(i, path)
		if printInfo:
			print("Cleaned BonePath: "+polygon2d.get_bone_path(i).get_concatenated_names())

	# Step 1. Remove the bones that doesn't exist in the skeleton
	for i in polyBoneCount:
		var polybone = polygon2d.get_bone_path(i)
		var polygon2dIndex: int = find_bone_index_in_skeleton_2d(polybone, skeleton)
		if polygon2dIndex == INVALID_INDEX:
			bonesToProcess.append(i)
	for i in range(bonesToProcess.size()-1,-1,-1):
		polygon2d.erase_bone(bonesToProcess[i])
		msg = "Erased at " + str(bonesToProcess[i])
		if printInfo:
			print(msg)
	bonesToProcess.clear()
	# Step 2. Add the bones that doesn't exist in the polygon
	for i in skeleBoneCount:
		var skelebone: Bone2D = skeleton.get_bone(i)
		var boneInPolyIndex:int = find_bone_index_in_polygon_2d(skelebone, polygon2d)
		if boneInPolyIndex == INVALID_INDEX:
			bonesToProcess.append(i)
	var newWeights: PackedFloat32Array
	for poly in tempPolygons:
		newWeights.append(0)
	for i in bonesToProcess.size():
		var bone: Bone2D = skeleton.get_bone(bonesToProcess[i])
		polygon2d.add_bone(bone.get_path(), newWeights)
		msg = "Added at " + str(i)
		if printInfo:
			print(msg)
	# Step 3. Store the data according to the bone order.
	var paths: Array[NodePath]
	var weights: Array[PackedFloat32Array]
	for i in skeleton.get_bone_count():
		var skelebone: Bone2D = skeleton.get_bone(i)
		var skelebonePath: NodePath = skelebone.get_path()
		var index: int = find_bone_index_in_polygon_2d(skelebone, polygon2d)
		paths.append(polygon2d.get_bone_path(index))
		weights.append(polygon2d.get_bone_weights(index))
	# Step 4. Replace the current data in polygon with the rearanged one according to the bone order.
	polyBoneCount = polygon2d.get_bone_count()
	for i in polyBoneCount:
		if i < skeleton.get_bone_count():
			print("size:"+str(polyBoneCount)+", index:"+str(i)+", data:"+paths[i].get_concatenated_names())
			polygon2d.set_bone_path(i, paths[i])
			polygon2d.set_bone_weights(i, weights[i])
	#	else:
	#		polygon2d.erase_bone(i)
	#		i-=1
	return ""

static func delete_bone_weights_for_vertex(polygon2d: Polygon2D, vertexIndex: int, printInfo:bool = false) -> Array[PackedFloat32Array]:
	# Weight
	var weightsCopy: Array[PackedFloat32Array]
	var boneCount:int = polygon2d.get_bone_count()
		# Passing throught all bones
	for bone in boneCount:
		if printInfo:
			print("bone "+str(bone)+" in a "+str(boneCount) + "-1 list size")
		var tempWeights: PackedFloat32Array
		var actualWeights: PackedFloat32Array = polygon2d.get_bone_weights(bone)
		var count:int = 0
		for weight in actualWeights:
			# Recreating bone weights without the weight at selected index to delete it form the list
			if count != vertexIndex:
				tempWeights.append(weight)
			else:
				if printInfo:
					print("-> deleting weight "+str(count)+" at bone "+str(bone))
			count = count + 1
		# Storing recreated weights
		weightsCopy.append(tempWeights)
	return weightsCopy

static func delete_bone_weights_for_vertices(polygon2d: Polygon2D, vertexIndexes: Array[int], printInfo:bool = false) -> Array[PackedFloat32Array]:
	# Weight
	var weightsCopy: Array[PackedFloat32Array]
	var boneCount:int = polygon2d.get_bone_count()
		# Passing throught all bones
	for bone in boneCount:
		if printInfo:
			print("bone "+str(bone)+" in a "+str(boneCount) + "-1 list size")
		var tempWeights: PackedFloat32Array
		var actualWeights: PackedFloat32Array = polygon2d.get_bone_weights(bone)
		var count:int = 0
		for weight in actualWeights:
			var markedForDeletion:bool = false
			for index in vertexIndexes:
				if count == index:
					markedForDeletion = true
					break
			if not markedForDeletion:
				tempWeights.append(weight)
			else:
				if printInfo:
					print("-> deleting weight "+str(count)+" at bone "+str(bone))
			count = count + 1
		# Storing recreated weights
		weightsCopy.append(tempWeights)
	return weightsCopy

static func are_points_and_uv_equal_size(polygon2d: Polygon2D)->bool:
	if polygon2d.polygon.size() == polygon2d.uv.size():
		return true
	return false

static func triangulate_polygons(polygon2d: Polygon2D)->bool:
	if polygon2d.polygon.size() < 3:
		print("You can't triangulate anything with less than 3 vertex.")
		return false
	polygon2d.polygons = []
	var points:PackedInt32Array = triangulate(polygon2d)
	var ok:bool = false
	for vIndex in range(0, points.size(), 3):
		var vIndex2 = vIndex+1
		var vIndex3 = vIndex+2
		if vIndex2 == points.size():
			vIndex2 = 0
			vIndex3 = 1
		elif vIndex3 == points.size():
			vIndex3 = 0
		var polygonShape: PackedVector2Array = polygon2d.polygon.slice(0, polygon2d.polygon.size() - polygon2d.internal_vertex_count)
		var currentTriangleIndexes: PackedInt32Array
		var index1:int = points[vIndex]
		var index2:int = points[vIndex2]
		var index3:int = points[vIndex3]
		currentTriangleIndexes.append(index1)
		currentTriangleIndexes.append(index2)
		currentTriangleIndexes.append(index3)
		var vertex1: Vector2 = polygon2d.polygon[index1]
		var vertex2: Vector2 =  polygon2d.polygon[index2]
		var vertex3: Vector2 =  polygon2d.polygon[index3]
		var vertices: PackedVector2Array
		vertices.append(vertex1)
		vertices.append(vertex2)
		vertices.append(vertex3)
		if Geometry2D.intersect_polygons(vertices, polygonShape).size()>0:
			polygon2d.polygons.append(currentTriangleIndexes)
			ok = true
	return ok

static func find_bone_index_by_path(skeleton:Skeleton2D, path:NodePath)->int:
	for i in skeleton.get_bone_count():
		var bone:Bone2D = skeleton.get_bone(i)
		bone.get_path().get_concatenated_names()
		var boneName: StringName = bone.get_path().get_name(bone.get_path().get_name_count()-1)
		var pathName: StringName = path.get_name(path.get_name_count()-1)
		if boneName == pathName:
			return i
	return -1

static func triangulate(polygon2d: Polygon2D)->PackedInt32Array:
	if polygon2d.polygon.size() < 3:
		return []
	polygon2d.polygons = []
	var points:PackedInt32Array = Geometry2D.triangulate_delaunay(polygon2d.polygon)
	if points.size() > 0:
		return points
	points = Geometry2D.triangulate_polygon(polygon2d.polygon)
	if points.size() > 0:
		return points
	return []

## The origin in this case is 0,0
static func calculate_rotated_point_2d_degree(point: Vector2, degree:float, multiplier:int = 1)->Vector2:
	if degree == 0:
		return Vector2(point.x, point.y)
	return calculate_rotated_point_2d(point, ((degree * multiplier) * PI) / 180)

## The origin in this case is 0,0
static func calculate_rotated_point_2d(point: Vector2, angleRadian:float)->Vector2:
	if angleRadian == 0:
		return Vector2(point.x, point.y)
	var newX: float = (point.x * cos(angleRadian)) - (point.y * sin(angleRadian))
	var newY: float = (point.x * sin(angleRadian)) + (point.y * cos(angleRadian))
	return Vector2(newX, newY)

## The origin is specified in there
static func calculate_rotated_point_2d_around_origin_degree(origin: Vector2, point: Vector2, degree: float)->Vector2:
	return calculate_rotated_point_2d_around_origin(origin, point, (degree  * PI) / 180)

## The origin is specified in there
static func calculate_rotated_point_2d_around_origin(origin: Vector2, point: Vector2, angleRadian: float)->Vector2:
	var newX: float = origin.x + ((point.x) * cos(angleRadian)) - ((point.y) * sin(angleRadian))
	var newY: float = origin.y + ((point.x) * sin(angleRadian)) + ((point.y) * cos(angleRadian))
	return Vector2(newX, newY)

static func calculate_rotated_limits(width: float, height: float, factor: float = 2, pos: Vector2 = Vector2.ZERO, offset: Vector2 = Vector2.ZERO, angle: float = 0)-> PackedVector2Array:
	var result: PackedVector2Array
	var rotated: Vector2
	var xPoint: float
	var yPoint: float
	# Upper Right 
	xPoint = -(width / factor) + offset.x
	yPoint = -(height / factor) + offset.y
	rotated = pos + NeuroArkPolygon2dTools.calculate_rotated_point_2d(Vector2(xPoint, yPoint), angle)
	result.append(rotated)
	# Upper Left
	xPoint =  (width / factor) + offset.x
	yPoint = -(height / factor) + offset.y
	rotated = pos + NeuroArkPolygon2dTools.calculate_rotated_point_2d(Vector2(xPoint, yPoint), angle)
	result.append(rotated)
	# Lower Left
	xPoint =  (width / factor) + offset.x
	yPoint =  (height / factor) + offset.y
	rotated = pos + NeuroArkPolygon2dTools.calculate_rotated_point_2d(Vector2(xPoint, yPoint), angle)
	result.append(rotated)
	# Lower Right
	xPoint =  -(width / factor) + offset.x
	yPoint =  (height / factor) + offset.y
	rotated = pos + NeuroArkPolygon2dTools.calculate_rotated_point_2d(Vector2(xPoint, yPoint), angle)
	result.append(rotated)
	return result

static func get_limit_names() -> PackedStringArray:
	var names: PackedStringArray
	names.append("BOX_UPPER_RIGHT_INDEX")
	names.append("BOX_UPPER_LEFT_INDEX")
	names.append("BOX_LOWER_LEFT_INDEX")
	names.append("BOX_LOWER_RIGHT_INDEX")
	return names

static func get_limit_name(limitIndex: int) -> String:
	var names: PackedStringArray = get_limit_names()
	return names[limitIndex] if limitIndex < names.size() else ""

static func remove_nans_from_vector(vector:Vector2)-> Vector2:
	if is_nan(vector.x):
		vector.x = 0
	if is_nan(vector.y):
		vector.y = 0
	return vector

static func find_limits_in_polygon(vectors: PackedVector2Array)-> PackedFloat32Array:
	var result : PackedFloat32Array
	var start: float
	var end: float
	var ceil: float
	var floor: float
	for i in vectors.size():
		var x:float = vectors[i].x
		var y:float = vectors[i].y
		if i == 0:
			start = x
			end = x
			ceil = y
			floor = y
		else:
			if x < start:
				start = x
			if x > end:
				end = x
			if y < ceil:
				ceil = y
			if y > floor:
				floor = y
	var width: float = abs(end - start)
	var height: float = abs(ceil - floor)
	result.append(start)
	result.append(end)
	result.append(ceil)
	result.append(floor)
	result.append(width)
	result.append(height)
	return result

static func is_vector_in_polygon(vector: Vector2, polygonVectors: PackedVector2Array)-> bool:
	return is_vector_in_limits(vector, find_limits_in_polygon(polygonVectors))

static func is_vector_in_limits(vector: Vector2, limits: PackedFloat32Array)-> bool:
	if vector.x < limits[LIMIT_START_INDEX]:
		return false
	if vector.x > limits[LIMIT_END_INDEX]:
		return false
	if vector.y < limits[LIMIT_CEIL_INDEX]:
		return false
	if vector.y > limits[LIMIT_FLOOR_INDEX]:
		return false
	return true

static func find_closest_vertex(vertex:Vector2, polygon: PackedVector2Array, skipIndexes:PackedInt32Array = [])->int:
	var storedDistance: float = -1
	var storedIndex: int = -1
	for index in polygon.size():
		var banned:bool = false
		for i in skipIndexes.size():
			if skipIndexes[i] == index:
				banned = true
		if not banned:
			var distanceX = abs(vertex.x - polygon[index].x)
			var distanceY = abs(vertex.y - polygon[index].y)
			var distance = (distanceX + distanceY) / 2
			if index == 0:
				storedDistance = distance
				storedIndex = index
			else:
				if distance <= storedDistance:
					storedDistance = distance
					storedIndex = index
	return storedIndex

static func get_all_bone_paths_from_polygon2d(polygon2d: Polygon2D)-> Array:
	var array: Array = Array()
	var boneCount: int = polygon2d.get_bone_count()
	for bone in boneCount:
		var actualPaths: NodePath = polygon2d.get_bone_path(bone)
		array.append(actualPaths)
	return array

static func get_all_weights_from_polygon2d(polygon2d: Polygon2D)-> Array:
	var array: Array = Array()
	var boneCount: int = polygon2d.get_bone_count()
	for bone in boneCount:
		var actualWeights: PackedFloat32Array = polygon2d.get_bone_weights(bone)
		array.append(actualWeights)
	return array

static func get_all_bones_from_polygon2d(polygon2d: Polygon2D)-> Array:
	var array: Array = Array()
	var boneCount: int = polygon2d.get_bone_count()
	for bone in boneCount:
		var actualWeights: PackedFloat32Array = polygon2d.get_bone_weights(bone)
		array.append(actualWeights)
	return array	

static func set_all_weights_to_polygon2d(array: Array, polygon2d: Polygon2D)-> Polygon2D:
	var boneCount: int = array.size()
	for index in boneCount:
		var dictionary:Dictionary = array[index]
		var key = dictionary.keys()[0]
		var boneWeights = dictionary[key]
		var actualWeights: PackedFloat32Array = PackedFloat32Array()
		for i in range(0, boneWeights.size(), 1):
			actualWeights.append(boneWeights[i])
		polygon2d.set_bone_weights(index, actualWeights)
	return polygon2d

static func set_all_bones_path_to_polygon2d(array: Array, polygon2d: Polygon2D)-> Polygon2D:
	var boneCount: int = array.size()
	for index in boneCount:
		var path:String = array[index]
		var bonesPath:NodePath = NodePath(path)
		polygon2d.set_bone_path(index, bonesPath)
	return polygon2d

static func set_bones_to_polygon2d(paths: Array, weights: Array, polygon2d: Polygon2D, resetBones:bool = false)-> Polygon2D:
	var boneCount: int = paths.size()
	if resetBones:
		polygon2d.clear_bones()
	for index in boneCount:
		var dictionary:Dictionary = weights[index]
		var key = dictionary.keys()[0]
		var boneWeights = dictionary[key]
		var actualWeights: PackedFloat32Array = PackedFloat32Array()
		for i in range(0, boneWeights.size(), 1):
			actualWeights.append(boneWeights[i])
		var path: String = paths[index]
		var bonesPath: NodePath = NodePath(path)
		polygon2d.add_bone(bonesPath, actualWeights)
	return polygon2d

static func copy_polygon2d_weights(copyFrom: Polygon2D, copyTo: Polygon2D)-> Polygon2D:
	var boneCount:int = copyFrom.get_bone_count()
	for i in range(0, boneCount, 1):
		copyTo.set_bone_weights(i, copyFrom.get_bone_weights(i))
	return copyTo

static func copy_polygon2d_bones_path(copyFrom: Polygon2D, copyTo: Polygon2D)-> Polygon2D:
	var boneCount:int = copyFrom.get_bone_count()
	for i in range(0, boneCount, 1):
		copyTo.set_bone_path(i, copyFrom.get_bone_path(i))
	return copyTo

static func copy_polygon2d_bones(copyFrom: Polygon2D, copyTo: Polygon2D, resetBones: bool = false)-> Polygon2D:
	if resetBones || copyFrom.get_bone_count() != copyTo.get_bone_count():
		copyTo.clear_bones()
	var boneCount:int = copyFrom.get_bone_count()
	for i in range(0, boneCount, 1):
		copyTo.add_bone(copyFrom.get_bone_path(i), copyFrom.get_bone_weights(i))
	copyFrom.notify_property_list_changed()
	return copyTo