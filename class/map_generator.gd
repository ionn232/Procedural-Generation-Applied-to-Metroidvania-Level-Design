class_name MapGenerator
extends Node2D

@export var map_size_x:int
@export var map_size_y:int

#var undefined_rooms : Array[MU] = [] 
#var finished_rooms : Array[MU] = [] #TODO: this can have a fixed size i think

func main_process() -> void:
	Level.map_size_x = map_size_x
	Level.map_size_y = map_size_y
	var main_map:Map = Map.new()
	main_map.initialize_map()
	Level.map = main_map
	
	#spawn room initialization
	var starting_coords:Vector2i = Vector2i(5, 5)
	var initial_MU = MU.createNew()
	initial_MU.define_pos(starting_coords)
	Level.map.MUs[starting_coords.x][starting_coords.y] = initial_MU
	initial_MU.assign_borders(Utils.border_type.WALL, Utils.border_type.WALL, Utils.border_type.WALL, Utils.border_type.WALL)
	var initial_room = Room.createNew(Vector2i(1, 1))
	initial_room.define_type(Utils.room_type.SPAWN)
	initial_room.add_MU(initial_MU)
	initial_room.define_pos(initial_MU.grid_pos)
	Level.initial_room = initial_room
	Level.rooms.push_back(initial_room)
	
	#second room TODO remove after tests
	var new_coords = starting_coords + Vector2i(1,0)
	var new_room = Room.createNew(Vector2i(5,4))
	new_room.define_pos(new_coords)
	new_room.createRoomMUs()
	Level.rooms.push_back(new_room)
	
	#room generation procedure - initial zone (first pass)
	#while undefined_rooms.front() != null:
		#var current_room = undefined_rooms.front()
		#print('new room --------------------------------------', current_room.grid_pos)
		#current_room.roll_borders_first_pass()
		#for direction in Utils.direction.values():
			##TODO: allow locked doors that only contain side upgrades as key which are placed on the current or previous passes
			#if (current_room.borders[direction] == Utils.border_type.EMPTY):
				#var new_coords = current_room.grid_pos + Utils.direction_to_vec2i(direction)
				##TODO: finished/unfinished status on room data instead of checking if exists on an array for better performance
				#if (is_in_grid(new_coords) && finished_rooms.find(Level.complete_map.MUs[new_coords.x][new_coords.y]) == -1 && undefined_rooms.find(Level.complete_map.MUs[new_coords.x][new_coords.y]) == -1):
					#var new_room = MU.createNew()
					#new_room.define_pos(new_coords)
					#undefined_rooms.push_back(new_room)
					#Level.complete_map.MUs[new_coords.x][new_coords.y] = new_room
		#var finished_room = undefined_rooms.pop_front()
		#finished_rooms.push_back(finished_room)
		#DEBUG_check_borders(finished_room)
	#
	#
	#DEBUG_check_paths()

#checks if a position is out of bounds, and if it is modifies the adjacent room's connecting direction into a wall
#TODO: creo que no es necesario convertir en muros. Testear. Si no es necesario sustituir por la funcion en Utils
#func is_in_grid(pos:Vector2i) -> bool:
	#var off_direction:Array[Utils.direction] = []
	#
	#if (pos.x >= map_size_x):
		#off_direction.push_back(Utils.direction.RIGHT)
	#elif (pos.y >= map_size_y):
		#off_direction.push_back(Utils.direction.DOWN)
	#if (pos.x < 0):
		#off_direction.push_back(Utils.direction.LEFT)
	#elif (pos.y < 0):
		#off_direction.push_back(Utils.direction.UP)
	#
	#if off_direction.size() > 0:
		#for direction in off_direction:
			#var actual_room_pos = pos - Utils.direction_to_vec2i(direction)
			#Level.map.MUs[actual_room_pos.x][actual_room_pos.y].borders[direction] = Utils.border_type.WALL
		#return false
	#return true

func DEBUG_check_borders(mu:MU):
	print('up: ', mu.borders[Utils.direction.UP])
	print('down: ', mu.borders[Utils.direction.DOWN])
	print('left: ', mu.borders[Utils.direction.LEFT])
	print('right: ', mu.borders[Utils.direction.RIGHT])

#func DEBUG_check_paths():
	#print('---------------------------checking paths------------------------')
	#var trueCount:int = 0
	#for room:MU in finished_rooms:
		#var traversable:bool = traversableArea.exists_path(Level.initial_room.grid_pos, room.grid_pos)
		#if (traversable):
			#trueCount += 1
	#print('number of traversable MUs (including starting): ', trueCount)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_process()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
