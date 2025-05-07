class_name MapGenerator
extends Node2D

@onready var ui: CanvasLayer = $"../UI"

@export var map_size_x:int
@export var map_size_y:int

@export var route_steps:int
@export var number_of_areas:int
@export var world_size_factor:float

@export var area_size_factor:float

func _ready() -> void: ##level and map initializations
	Level.map_size_x = map_size_x
	Level.map_size_y = map_size_y
	var main_map:Map = Map.new()
	main_map.initialize_map()
	Level.map = main_map
	ui.stage_changed.connect(_stage_handler.bind())

func _stage_handler():
	match(Utils.generator_stage):
		1:
			step_1()
			pass
		2:
			step_2()
			pass

func step_1(): ##1: place as many points as the number of areas
	var area_points : Array[AreaPoint] = []
	area_points.resize(number_of_areas)
	for i in range(number_of_areas):
		#TODO better random procedure
		var current_area_point = AreaPoint.createNew(Vector2(randf_range(0, map_size_x), randf_range(0, map_size_y)))
		area_points[i] = current_area_point
	Level.area_points = area_points

func step_2(): ##expand points from centroid and each other
	#calculate centroid
	var centroid : Vector2 = Vector2(0,0)
	for area_point:AreaPoint in Level.area_points:
		centroid += area_point.pos
	centroid.x /= len(Level.area_points)
	centroid.y /= len(Level.area_points)
	#expand areas from centroid
	for current_point:AreaPoint in Level.area_points:
		var centroid_to_area = centroid.direction_to(current_point.pos)
		current_point.update_position(current_point.pos + centroid_to_area * randf_range(0, world_size_factor * 16)) #TODO: better randomness alg
	#expand areas from each other
	#TODO: tweak parameters
	var min_proximity:float = (map_size_x + map_size_y)*16 / float(number_of_areas * 1.5)
	var clear = false
	while (!clear): #TODO: clamp limits, avoid potential infinite loops
		clear = true
		for current_point:AreaPoint in Level.area_points:
			for second_point:AreaPoint in Level.area_points:
				if current_point == second_point: pass
				else:
					var distance:float = current_point.pos.distance_to(second_point.pos)
					if (distance < min_proximity):
						var second_to_current = second_point.pos.direction_to(current_point.pos)
						current_point.update_position(current_point.pos + second_to_current * (min_proximity - distance + 1))
						clear = false

func TEST_rooms():
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

func DEBUG_check_borders(mu:MU):
	print('up: ', mu.borders[Utils.direction.UP])
	print('down: ', mu.borders[Utils.direction.DOWN])
	print('left: ', mu.borders[Utils.direction.LEFT])
	print('right: ', mu.borders[Utils.direction.RIGHT])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
