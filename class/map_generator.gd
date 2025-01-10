class_name MapGenerator
extends Node2D

@export var map_size_x:int = 40
@export var map_size_y:int = 35

func main_process() -> void:
	Utils.initialize_room_data(map_size_x, map_size_y)
	
	var undefined_rooms : Array[Room] = [] 
	var finished_rooms : Array[Room] = []
	
	#initial room initialization
	var starting_coords:Vector2i = Vector2i(randi_range(0, map_size_x - 1), randi_range(0, map_size_y - 1))
	var initial_room = Room.new()
	initial_room.define_data(starting_coords, 'initial room;')
	undefined_rooms.push_back(initial_room)
	Utils.rooms[starting_coords.x][starting_coords.y] = initial_room
	
	#room generation procedure (first pass)
	while undefined_rooms.front() != null:
		var current_room = undefined_rooms.front()
		print('new room --------------------------------------', current_room.grid_pos)
		current_room.roll_borders()
		for direction in Utils.border.values():
			if (current_room.borders[direction] == Utils.border_type.EMPTY || current_room.borders[direction] == Utils.border_type.LOCKED_DOOR):
				var new_coords = current_room.grid_pos + Utils.border_to_vec2i(direction)
				if (is_in_grid(new_coords) && finished_rooms.find(Utils.rooms[new_coords.x][new_coords.y]) == -1 && undefined_rooms.find(Utils.rooms[new_coords.x][new_coords.y]) == -1):
					var new_room = Room.new()
					new_room.define_data(new_coords, 'powerups n gates n shit')
					undefined_rooms.push_back(new_room)
					Utils.rooms[new_coords.x][new_coords.y] = new_room
		var finished_room = undefined_rooms.pop_front()
		finished_rooms.push_back(finished_room)
		DEBUG_check_borders(finished_room)
		print('pending rooms length: ', undefined_rooms.size())
		print('finished rooms length: ', finished_rooms.size())
	print('--------------------------finished---------------------------------')

#checks if a position is out of bounds, and if it is makes the adjacent room's connecting border a wall
func is_in_grid(pos:Vector2i) -> bool:
	var off_direction:Array[Utils.border] = []
	
	if (pos.x >= map_size_x):
		off_direction.push_back(Utils.border.RIGHT)
	elif (pos.y >= map_size_y):
		off_direction.push_back(Utils.border.DOWN)
	if (pos.x < 0):
		off_direction.push_back(Utils.border.LEFT)
	elif (pos.y < 0):
		off_direction.push_back(Utils.border.UP)
	
	if off_direction.size() > 0:
		for direction in off_direction:
			var actual_room_pos = pos - Utils.border_to_vec2i(direction)
			Utils.rooms[actual_room_pos.x][actual_room_pos.y].borders[direction] = Utils.border_type.WALL
		return false
	return true

func DEBUG_check_borders(room:Room):
	print('up: ', room.borders[Utils.border.UP])
	print('down: ', room.borders[Utils.border.DOWN])
	print('left: ', room.borders[Utils.border.LEFT])
	print('right: ', room.borders[Utils.border.RIGHT])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_process()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
