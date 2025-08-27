@tool
extends Node
class_name NeuroArkMathTools

## Numeric tools
static func isNumberInRange(number:float, start:float, end:float)->bool:
	if start == end:
		return false
	if start > end:
		if number >= end && number <= start:
			return true
	elif start < end:
		if number >= start && number <= end:
			return true
	return false

static func reduce_until(point:float, substract:float, until:float)->float:
	if point == until:
		return point
	if point < until:
		if point > substract:
			return until
		else:
			return point + substract
	elif point > until:
		if point < substract:
			return until
		else:
			return point - substract
	return point

static func create_number_label(number)-> String:
	if number is int:
		return str(number)+"."+"000"
	if number is float:
		var numberString: String = str(number)
		if numberString.contains("."):
			var indexPoint: int = numberString.find(".")
			var integers: String =  numberString.substr(0, indexPoint)
			var decimals: String =  numberString.substr(indexPoint+1, 3)
			return integers+"."+decimals
		else:
			return numberString+"."+"000"
	else :
		return "e3"
