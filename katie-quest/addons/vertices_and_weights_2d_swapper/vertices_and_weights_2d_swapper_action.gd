@tool
extends Node
class_name NeuroArkSwapper2DTools

static func swap_vertices_h(packed: PackedVector2Array) -> PackedVector2Array:
	var minX: float = 0
	var minY: float = 0
	var maxX: float = 0
	var maxY: float = 0
	var count: int = 0
	for vector in packed:
		var point: Vector2 = vector
		if (count == 0) :
			minX = point.x
			maxX = point.x;
			minY = point.y;
			maxY = point.y;
		else :
			if (point.x < minX) :
				minX = point.x
			if (point.y < minY) :
				minY = point.y
			if (point.x > maxX) :
				maxX = point.x
			if (point.y > maxY) :
				maxY = point.y
		count = count + 1
	var polygonWidth: float = abs(maxX - minX)
	var polygonHeight: float = abs(maxY - minY)
	var middlePointH: float = minX + (polygonWidth / 2)
	var middlePointV: float = minY + (polygonHeight / 2)
	count = 0
	for vector in packed:
		var point: Vector2 = vector
		var distance_from_middle: float = middlePointH - point.x
		point.x = middlePointH + distance_from_middle
		packed.set(count, point)
		count = count + 1
	return packed

static func swap_vertices_v(packed: PackedVector2Array) -> PackedVector2Array:
	var minX: float = 0
	var minY: float = 0
	var maxX: float = 0
	var maxY: float = 0
	var count: int = 0	
	for vector in packed:
		var point: Vector2 = vector
		if (count == 0) :
			minX = point.x
			maxX = point.x
			minY = point.y
			maxY = point.y
		else :
			if (point.x < minX) :
				minX = point.x
			if (point.y < minY) :
				minY = point.y
			if (point.x > maxX) :
				maxX = point.x
			if (point.y > maxY) :
				maxY = point.y
		count = count + 1

	var polygonWidth: float = abs(maxX - minX)
	var polygonHeight: float = abs(maxY - minY)
	var middlePointH: float = minX + (polygonWidth / 2)
	var middlePointV: float = minY + (polygonHeight / 2)
	count = 0
	for vector in packed:
		var point: Vector2 = vector
		var distance_from_middle: float = middlePointV - point.y
		point.y = middlePointV + distance_from_middle
		packed.set(count, point)
		count = count + 1
	return packed
	
static func copy_and_fill_int32Array(array: PackedFloat32Array, value: float) -> PackedFloat32Array :
	var copy: PackedFloat32Array = PackedFloat32Array(array)
	for i in copy.size() :
		copy.set(i, value)
	return copy
	

