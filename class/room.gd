class_name Room
extends Node2D

#var up:utils.border_type
#var down:utils.border_type
#var left:utils.border_type
#var right:utils.border_type
#var data:String

var borders: Dictionary

func define(up: Utils.border_type, down: Utils.border_type, left: Utils.border_type, right: Utils.border_type, data: String): 
	borders = {
		"up": up,
		"down": down,
		"left": left,
		"right": right,
		"data": data,
	}
