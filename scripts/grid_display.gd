extends Node2D

@onready var camera: Camera2D = $"../Camera2D"

const GRID_SIZE = 16
const LINE_WIDTH = 2

func _draw():
	##static grid, fixed size
	#var range_x = Level.map_size_x
	#var range_y = Level.map_size_y
	#
	#var top_left : Vector2i = Vector2i(-4 - range_x/2 * 16, -4 - range_y/2 * 16)
	#for i in range(range_x):
		#for j in range(range_y):
			#var square = Rect2i(top_left.x + i*GRID_SIZE ,top_left.y + j*GRID_SIZE , GRID_SIZE, GRID_SIZE)
			#draw_rect(square, Color(1,1,1,0.2) ,false, LINE_WIDTH)
			
	var range_x = Level.map_size_x * GRID_SIZE
	var range_y = Level.map_size_y * GRID_SIZE
	var top_left : Vector2i = Vector2i(-4 - range_x/2, -4 - range_y/2)
	var i:int = 0
	var j:int = 0
	var current_column_origin:Vector2 = top_left
	var current_row_origin:Vector2 = top_left
	while i <= range_y:
		draw_line(current_row_origin, current_row_origin + range_x * Vector2(1,0), Color(1,1,1,0.2), LINE_WIDTH, false)
		current_row_origin.y += GRID_SIZE
		i += GRID_SIZE
	while j <= range_x:
		draw_line(current_column_origin, current_column_origin + range_y * Vector2(0, 1), Color(1,1,1,0.2), LINE_WIDTH, false)
		current_column_origin.x += GRID_SIZE
		j += GRID_SIZE
	
