class_name MapGenerator
extends Node2D

@export var map_size_x:int
@export var map_size_y:int

var undefined_rooms : Array[Room] = [] 
var finished_rooms : Array[Room] = [] #TODO: this can have a fixed size i think

var ordered_rooms_isolated : Array[Room] = []

func main_process() -> void:
	Level.map_size_x = map_size_x
	Level.map_size_y = map_size_y
	var main_map:Map = Map.new()
	main_map.initialize_map()
	Level.complete_map = main_map
	
	#initial room initialization
	var starting_coords:Vector2i = Vector2i(randi_range(0, map_size_x - 1), randi_range(0, map_size_y - 1))
	var initial_room = Room.createNew()
	initial_room.define_pos(starting_coords)
	initial_room.define_data('initial room; ')
	undefined_rooms.push_back(initial_room)
	Level.complete_map.rooms[starting_coords.x][starting_coords.y] = initial_room
	Level.initial_room = initial_room
	
	#room generation procedure - initial zone (first pass)
	while undefined_rooms.front() != null:
		var current_room = undefined_rooms.front()
		print('new room --------------------------------------', current_room.grid_pos)
		current_room.roll_borders_first_pass()
		for direction in Utils.direction.values():
			#TODO: allow locked doors that only contain side upgrades as key which are placed on the current or previous passes
			if (current_room.borders[direction] == Utils.border_type.EMPTY):
				var new_coords = current_room.grid_pos + Utils.direction_to_vec2i(direction)
				#TODO: finished/unfinished status on room data instead of checking if exists on an array for better performance
				if (is_in_grid(new_coords) && finished_rooms.find(Level.complete_map.rooms[new_coords.x][new_coords.y]) == -1 && undefined_rooms.find(Level.complete_map.rooms[new_coords.x][new_coords.y]) == -1):
					var new_room = Room.createNew()
					new_room.define_pos(new_coords)
					undefined_rooms.push_back(new_room)
					Level.complete_map.rooms[new_coords.x][new_coords.y] = new_room
		var finished_room = undefined_rooms.pop_front()
		finished_rooms.push_back(finished_room)
		DEBUG_check_borders(finished_room)
	
	#room generation procedure - isolated and memorable room weight
	for room:Room in finished_rooms:
		var steps_to_intersection:int = isolated_room_weight(room);
		room.weights[Utils.room_weights.ISOLATED] = steps_to_intersection
		room.weights[Utils.room_weights.MEMORABLE] = 1.0/float(steps_to_intersection)
	##print('number of rooms: ', finished_rooms.size(), ' // number of calls: ', Room.DEBUG_count1, ' // number of complete calls: ', Room.DEBUG_count2)
	#room generation procedure - key-gate placement (first pass)
	
	
	#room generation procedure - key distance weight
	
	#start second pass
	
	DEBUG_check_paths()

#checks if a position is out of bounds, and if it is modifies the adjacent room's connecting direction into a wall
#TODO: creo que no es necesario convertir en muros. Testear. Si no es necesario sustituir por la funcion en Utils
func is_in_grid(pos:Vector2i) -> bool:
	var off_direction:Array[Utils.direction] = []
	
	if (pos.x >= map_size_x):
		off_direction.push_back(Utils.direction.RIGHT)
	elif (pos.y >= map_size_y):
		off_direction.push_back(Utils.direction.DOWN)
	if (pos.x < 0):
		off_direction.push_back(Utils.direction.LEFT)
	elif (pos.y < 0):
		off_direction.push_back(Utils.direction.UP)
	
	if off_direction.size() > 0:
		for direction in off_direction:
			var actual_room_pos = pos - Utils.direction_to_vec2i(direction)
			Level.complete_map.rooms[actual_room_pos.x][actual_room_pos.y].borders[direction] = Utils.border_type.WALL
		return false
	return true

func DEBUG_check_borders(room:Room):
	print('up: ', room.borders[Utils.direction.UP])
	print('down: ', room.borders[Utils.direction.DOWN])
	print('left: ', room.borders[Utils.direction.LEFT])
	print('right: ', room.borders[Utils.direction.RIGHT])

func DEBUG_check_paths():
	print('---------------------------checking paths------------------------')
	var trueCount:int = 0
	for room:Room in finished_rooms:
		var traversable:bool = traversableArea.exists_path(Level.initial_room.grid_pos, room.grid_pos)
		if (traversable):
			trueCount += 1
	
	print('number of traversable rooms (including starting): ', trueCount)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_process()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func isolated_room_weight(room:Room) -> float:
	if room.weights[Utils.room_weights.ISOLATED] == 0:
		room.weights[Utils.room_weights.ISOLATED] = null
	return room.weight_isolated_memorable()
