class_name MapGenerator
extends Node2D

@onready var ui: CanvasLayer = $"../UI"

@export var map_size_x:int
@export var map_size_y:int

@export var route_steps:int
@export var number_of_areas:int
@export var area_size_factor:float

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void: ##level and map initializations
	Level.map_size_x = map_size_x
	Level.map_size_y = map_size_y
	var main_map:Map = Map.new()
	main_map.initialize_map()
	Level.map = main_map
	ui.stage_changed.connect(_stage_handler.bind())
	#rng.seed = hash("test_seed")

func _stage_handler():
	match(Utils.generator_stage):
		1:
			step_1()
		2:
			step_2()
		3:
			step_3()
		4:
			step_4()
		5:
			pass
		6:
			pass
		7:
			pass
		8:
			pass

func step_1(): ##1: place as many points as the number of areas
	var area_points : Array[AreaPoint] = []
	area_points.resize(number_of_areas)
	for i in range(number_of_areas):
		#TODO better random procedure
		var current_area_point = AreaPoint.createNew(Vector2(rng.randf_range(-map_size_x/2.0, map_size_x/2.0), rng.randf_range(-map_size_y/2.0, map_size_y/2.0))) #TODO: better randomness alg
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
		var centroid_to_area:Vector2 = current_point.pos - centroid
		current_point.update_position(current_point.pos + centroid_to_area * 16) 
	#expand areas from each other
	#TODO: tweak parameters
	var min_distance:float = (map_size_x + map_size_y)*16 / float(number_of_areas * 1.5)
	var clear = false
	while (!clear): #TODO: clamp limits + avoid potential infinite loops
		clear = true
		for current_point:AreaPoint in Level.area_points:
			for second_point:AreaPoint in Level.area_points:
				if current_point == second_point: continue
				var distance:float = current_point.pos.distance_to(second_point.pos)
				if (distance < min_distance):
					var second_to_current = second_point.pos.direction_to(current_point.pos)
					current_point.update_position(current_point.pos + second_to_current * (min_distance - distance + 1))
					clear = false

func step_3(): ##establish initial area
	var rand_index :int = rng.randi_range(0, number_of_areas - 1) #TODO revisar rango esto. -1 o no??
	Level.initial_area = Level.area_points[rand_index]
	Level.initial_area.set_point_color(Utils.area_colors[0])

func step_4(): ##establish area connections
	#BUG: sometimes an area is isolated.
	for i:int in range(number_of_areas):
		compute_area_relations(i)
	join_stragglers()
	DEBUG_check_parity()

#TODO: tweak values
const MIN_ANGULAR_DISTANCE:float = PI/2.5
func compute_area_relations(index:int):
	var angles:Array = [] #type: float | null
	var angle_candidates:Array = [] #type: float | null
	angles.resize(number_of_areas)
	angle_candidates.resize(number_of_areas)
	var current_area:AreaPoint = Level.area_points[index]
	#record relative angles
	for j:int in range(number_of_areas):
		var second_area:AreaPoint = Level.area_points[j]
		if current_area == second_area: continue
		var angle = current_area.pos.angle_to_point(second_area.pos)
		angles[j] = angle
	#import existing relations for computation, remove from relation arrays
	for existing_relation:AreaPoint in current_area.relations:
		var existing_index:int = Level.area_points.find(existing_relation)
		angle_candidates[existing_index] = angles[existing_index]
		existing_relation.relations.erase(current_area)
	current_area.relations.resize(0)
	#compare angles and distances, decide area relations
	decide_relations(current_area, angles, angle_candidates)
	#establish relations between current area and each final candidate
	for j:int in range(number_of_areas):
		var final_candidate = angle_candidates[j] 
		if !final_candidate: continue
		if index==j: continue
		current_area.relations.push_back(Level.area_points[j])
		Level.area_points[j].relations.push_back(current_area)
		current_area.queue_redraw()

func decide_relations(current_area:AreaPoint, angles:Array, angle_candidates:Array):
	#var max_distance :float = (map_size_x + map_size_y)*16 / float(number_of_areas * 0.1) #TODO: tweak n use this maybe
	for j:int in range(number_of_areas):
		var second_area_angle = angles[j]
		if !second_area_angle: continue
		#check if area is suitable
		var suitable = true
		for k:int in range(number_of_areas):
			var existing_relation_angle = angle_candidates[k]
			if j==k: continue
			if !existing_relation_angle: continue 
			if abs(existing_relation_angle - second_area_angle) < MIN_ANGULAR_DISTANCE:
				suitable = false
				var distance_existing:float = current_area.pos.distance_squared_to(Level.area_points[k].pos)
				var distance_new:float = current_area.pos.distance_squared_to(Level.area_points[j].pos)
				if distance_new < distance_existing:
					angle_candidates[k] = null
					angle_candidates[j] = angles[j]
		if suitable:
			angle_candidates[j] = second_area_angle #TODO: introduce randomness to make it more interesting

func join_stragglers():
	for current_area:AreaPoint in Level.area_points:
		if len(current_area.relations) == 0:
			print('lone area: ', Level.area_points.find(current_area))
			var min_dist:float = INF
			var closest_area_index:int
			for i:int in range(number_of_areas):
				var second_area:AreaPoint = Level.area_points[i]
				if current_area == second_area: continue
				var distance_sq:float = current_area.pos.distance_squared_to(second_area.pos)
				if distance_sq < min_dist:
					min_dist = distance_sq
					closest_area_index = i
			current_area.relations.push_back(Level.area_points[closest_area_index])
			Level.area_points[closest_area_index].relations.push_back(current_area)

func DEBUG_check_parity():
	var parity = true
	for area:AreaPoint in Level.area_points:
		for relation:AreaPoint in area.relations:
			if !area in relation.relations:
				parity = false
				print('non-compliant: ', Level.area_points.find(area), ' // ' , Level.area_points.find(relation))
	print('parity holds: ', parity)

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
