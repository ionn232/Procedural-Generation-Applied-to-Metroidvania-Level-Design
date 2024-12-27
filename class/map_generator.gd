class_name MapGenerator
extends Node2D

@export var map_size_x:int = 10
@export var map_size_y:int = 10

var rooms:Array[Array] = []

func main_process() -> void:
	initialize_room_data()
	
	var undefined_rooms : Array[Room] = [] 
	
	#initial room
	var starting_coords:Vector2i = Vector2i(randi_range(0, map_size_x - 1), randi_range(0, map_size_y - 1))
	var initial_room = Room.new()
	initial_room.define_data(starting_coords, 'powerups n gates n shit')
	initial_room.roll_borders()
	undefined_rooms.push_back(initial_room)
	rooms[starting_coords.x][starting_coords.y] = initial_room
	
	#room generation procedure (first pass)
	while undefined_rooms.front() != null:
		var current_room = undefined_rooms.front()
		#Create adjacent rooms
		var border:Utils.border = Utils.border.UP
		for border_type in current_room.borders:
			if (border_type == Utils.border_type.EMPTY || border_type == Utils.border_type.LOCKED_DOOR):
				var current_coords = current_room.grid_pos + Utils.border_to_vec2i(border)
				if (is_in_grid(current_coords)):
					var new_room = Room.new()
					new_room.define_data(current_coords, 'powerups n gates n shit')
					new_room.roll_borders()
					undefined_rooms.push_back(new_room)
					rooms[current_coords.x][current_coords.y] = new_room
			border += 1
		undefined_rooms.pop_front()
	
	print('finished')
	

#returns a set of weights in a vector4
#func adjacent_room_weights(position:Vector2i) -> Array[float]:
	#var room_data:Room = rooms[position.x][position.y]
	#var room_weights: Array[float]
	#room_weights.resize(4)
	#
	#var i:int = 0
	#for element in room_data.borders:
		#match element:
			#Utils.border_type.EMPTY:
				#room_weights[i] = 1.0
				#pass
			#Utils.border_type.WALL:
				#room_weights[i] = 0.0
				#pass
			#Utils.border_type.DEATH_ZONE:
				#room_weights[i] = 0.0
				#pass
			#Utils.border_type.LOCKED_DOOR:
				#room_weights[i] = 1.0
				#pass
			#_:
				#pass
		#i += 1
	#return room_weights

#checks if a room is out of bounds, and if it is makes the adjacent room's connecting border a wall
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
			rooms[actual_room_pos.x][actual_room_pos.y].borders[direction] = Utils.border_type.WALL
		return false
	return true

func initialize_room_data():
	rooms.resize(map_size_x)
	for i in rooms.size():
		var room_column:Array[Room] = []
		room_column.resize(map_size_y)
		room_column.fill(null)
		rooms[i] = room_column

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_process()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
