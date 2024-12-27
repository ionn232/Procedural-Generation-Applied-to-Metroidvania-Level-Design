class_name Room
extends Node2D

var grid_pos:Vector2i
#up, down, left, right
var borders:Array[Utils.border_type] = []

var data:String


func assign_borders(up: Utils.border_type, down: Utils.border_type, left: Utils.border_type, right: Utils.border_type): 
	borders[Utils.border.UP] = up
	borders[Utils.border.DOWN] = down
	borders[Utils.border.LEFT] = left
	borders[Utils.border.RIGHT] = right


func define_data(pos:Vector2i, data: String):
	borders.resize(4)
	grid_pos = pos
	self.data = data

#weights must have 4 entries
func roll_borders():
	for direction in Utils.border:
		var value = Utils.border[direction]
		#replace behaviour
		if (value == Utils.border.UP || value==Utils.border.LEFT):
			borders[value] = Utils.border_type.EMPTY;
		else:
			borders[value] = Utils.border_type.WALL;
