extends Node2D

@onready var camera: Camera2D = $"../Camera2D"

const GRID_SIZE = 16
const LINE_WIDTH = 2

func _draw():
	##grid follows camera, dynamic size
	#var top_left:Vector2i = (camera.get_screen_center_position()) - get_viewport_rect().size/2
	#adjusted for the tilemap
	#var top_left_grid = Vector2i(top_left.x - 16 + (-4 - (top_left.x % 16)), top_left.y - 16 + (-4 - (top_left.y % 16)))

	#var top_left_grid_local = (top_left_grid)
	#var range_x:int = round(get_viewport_rect().size.x / 16) + 2
	#var range_y:int = round(get_viewport_rect().size.y / 16) + 2
	#
	#for i in range(range_x):
		#for j in range(range_y):
			#var square = Rect2i(top_left_grid_local.x + i*GRID_SIZE ,top_left_grid_local.y + j*GRID_SIZE , GRID_SIZE, GRID_SIZE)
			#draw_rect(square, Color(1,1,1,0.2) ,false, 1.0)
			
	##static grid, fixed size
	var range_x = Level.map_size_x
	var range_y = Level.map_size_y
	
	var top_left : Vector2i = Vector2i(-4 - range_x/2 * 16, -4 - range_y/2 * 16)
	for i in range(range_x):
		for j in range(range_y):
			var square = Rect2i(top_left.x + i*GRID_SIZE ,top_left.y + j*GRID_SIZE , GRID_SIZE, GRID_SIZE)
			draw_rect(square, Color(1,1,1,0.2) ,false, LINE_WIDTH)
