class_name MapGenerator
extends Node2D

@onready var ui: CanvasLayer = $"../UI"

@export var map_size_x:int
@export var map_size_y:int

@export_range (1,25) var number_route_steps:int
@export_range (1,25) var number_of_areas:int
@export_range (0, 9) var number_side_upgrades:int

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

#TODO tweak and separate x, y
var area_size:float

func _ready() -> void: ##level, map initializations // rng seeding
	ui.stage_changed.connect(_stage_handler.bind())
	rng.seed = hash("1")
	
	#initialize map
	Level.map_size_x = map_size_x
	Level.map_size_y = map_size_y
	var main_map:Map = Map.new()
	main_map.initialize_map()
	Level.map = main_map
	
	#TODO tweak and separate x, y
	area_size = (map_size_x + map_size_y)*16 / float(number_of_areas * 1.5)
	
	#load reward pool
	RewardPool.import_reward_pool()
	#distribute rewards amongst route steps #TODO: stat upgrades, equipment and collectibles
	var route_steps:Array[RouteStep]
	route_steps.resize(number_route_steps)
	var keyset_indexes:Array = range(len(RewardPool.keyset))
	var side_indexes:Array = range(len(RewardPool.side_upgrades))
	var side_upgrades_left:int = number_side_upgrades
	for i:int in range(number_route_steps):
		route_steps[i] = RouteStep.createNew(i)
		#assign RS main key
		var indexes_random_index:int = rng.randi_range(0, len(keyset_indexes)-1)
		route_steps[i].add_key(RewardPool.keyset[keyset_indexes.pop_at(indexes_random_index)])
		#assign side upgrades
		var RS_side_weight:float = side_upgrades_left / float(number_route_steps - i)
		while RS_side_weight > 1.0: #TODO: reuse procedure in step 8 to a separate function
			indexes_random_index = rng.randi_range(0, len(side_indexes)-1)
			route_steps[i].add_reward(RewardPool.side_upgrades[side_indexes.pop_at(indexes_random_index)])
			side_upgrades_left -= 1
			RS_side_weight -= 1.0
		var roll = rng.randf()
		if roll < RS_side_weight:
			indexes_random_index = rng.randi_range(0, side_upgrades_left - 1)
			route_steps[i].add_reward(RewardPool.side_upgrades[side_indexes.pop_at(indexes_random_index)])
			var debug_val = route_steps[i].reward_pool
			side_upgrades_left -= 1
	Level.route_steps = route_steps

func _stage_handler(): #TODO: queue point redraws each step instead of whatever is done now
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
			step_5()
		6:
			step_6()
		7:
			step_7()
		8:
			step_8()
		9:
			step_9()

func step_1(): ##1: place as many points as the number of areas
	var area_points : Array[AreaPoint] = []
	area_points.resize(number_of_areas)
	spawn_points(area_points, Vector2(map_size_x, map_size_y), true)
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
	var clear = false
	while (!clear): #TODO: clamp limits + avoid potential infinite loops
		clear = true
		for current_point:AreaPoint in Level.area_points:
			for second_point:AreaPoint in Level.area_points:
				if current_point == second_point: continue
				var distance:float = current_point.pos.distance_to(second_point.pos)
				if (distance < area_size):
					var second_to_current = second_point.pos.direction_to(current_point.pos)
					current_point.update_position(current_point.pos + second_to_current * (area_size - distance + 1))
					clear = false

func step_3(): ##establish initial area
	var rand_index :int = rng.randi_range(0, number_of_areas - 1) #TODO revisar rango esto. -1 o no??
	Level.initial_area = Level.area_points[rand_index]
	Level.initial_area.set_point_color(Utils.area_colors[0])

func step_4(): ##establish area connections #BUG: sometimes isolated segments are formed
	connect_points(Level.area_points)

func step_5(): ##designate area order by expanding from initial area, designate areas as progression or backtracking #BUG crashes program when isolated segments (fix step 4)
	#struct inits
	var ordered_areas:Array[AreaPoint] = []
	var available_routes:Array[Array] #Array of [origin: AreaPoint, routes: [AreaPoint]]
	var backtrack_routes:Array[Array] #Array of [origin: AreaPoint, routes: [AreaPoint]] TODO fill this
	var progression_routes:Array[Array] #Array of [origin: AreaPoint, routes: [AreaPoint]] TODO fill this
	ordered_areas.resize(number_of_areas)
	available_routes.resize(number_of_areas)
	backtrack_routes.resize(number_of_areas)
	progression_routes.resize(number_of_areas)
	#initial area (alredy known) #TODO:avoid repeating code, add to loop
	var initial_area:AreaPoint = Level.initial_area
	ordered_areas[0] = initial_area
	initial_area.set_point_color(Utils.area_colors[0])
	initial_area.area_index = 0
	initial_area.relation_is_progress.resize(len(initial_area.relations))
	initial_area.relation_is_progress.fill(false) #ts redundant, it's the default value
	initial_area.queue_redraw()
	for route_dest:AreaPoint in ordered_areas[0].relations:
		available_routes[0].push_back(route_dest)
	#produce ordered areas array and list of backtrack routes
	for i:int in range(number_of_areas):
		if i==0: continue
		var proceed:bool = false
		var expanding_area_index:int
		#roll expanding area
		while !proceed:
			proceed = true
			expanding_area_index = rng.randi_range(0, i-1)
			if len(available_routes[expanding_area_index]) == 0: proceed = false #area has no routes left to expand, reroll
		#roll next area
		var route_index:int = rng.randi_range(0, len(available_routes[expanding_area_index])-1)
		var new_area:AreaPoint = available_routes[expanding_area_index][route_index]
		#add new area to final lineup
		ordered_areas[i] = new_area
		new_area.set_point_color(Utils.area_colors[i])
		new_area.area_index = i
		new_area.relation_is_progress.resize(len(new_area.relations))
		new_area.relation_is_progress.fill(false) #ts redundant, it's the default value
		new_area.queue_redraw()
		#remove next area from elegibility: store progression and backtracking routes
		progression_routes[expanding_area_index].push_back(available_routes[expanding_area_index].pop_at(route_index))
		for current_route_list in available_routes: #TODO: introduce randomness (allow multiple entries to new area)
			current_route_list.erase(new_area)
			#TODO decide if saved to progression or not instead of saving to backtracking
			#var index:int = current_route_list.find(new_area)
			#if index != -1:
				#backtrack_routes[i].push_back(current_route_list.pop_at(index))
		#fill table: add routes from next area to unseen areas
		for route_dest:AreaPoint in ordered_areas[i].relations:
			if !ordered_areas.has(route_dest):
				available_routes[i].push_back(route_dest)
	#apply to singleton instance
	Level.area_points = ordered_areas
	#store progression//backtracking information
	for i:int in range(len(progression_routes)):
		if len(progression_routes[i]) == 0: continue
		var area_1:AreaPoint = ordered_areas[i]
		for j:int in range(len(progression_routes[i])):
			var area_2:AreaPoint = progression_routes[i][j]
			area_1.relation_is_progress[area_1.relations.find(area_2)] = true
			area_2.relation_is_progress[area_2.relations.find(area_1)] = true

func step_6(): ##establish hub-containing area
	#get area with most progression relations
	var hub_area:AreaPoint
	var max_num_relations:int = 0
	for i:int in range(len(Level.area_points)):
		var current_area = Level.area_points[i]
		var num_relations:int = current_area.relation_is_progress.reduce(
			func(accum:int, val:bool): return accum+int(val)
			, 0)
		if num_relations > max_num_relations:
			hub_area = current_area
			max_num_relations = num_relations
	#apply result
	hub_area.has_hub = true
	hub_area.queue_redraw()

func step_7(): ##establish area-rs relations
	var num_areas_left:int = number_of_areas
	var num_rs_left:int = number_route_steps
	var route_steps:Array[RouteStep] = Level.route_steps
	var area_index:int = 0
	for i:int in range(number_route_steps):
		#assign weight. for each whole 1.0 secures an area
		var RS_weight:float = num_areas_left / float(num_rs_left)
		var new_areas_this_iteration:int = 0 #used to prevent assigning the same area to a route step twice
		while RS_weight > 1.0:
			route_steps[i].areas.push_back(Level.area_points[area_index])
			num_areas_left -= 1
			area_index += 1
			RS_weight -= 1.0
			new_areas_this_iteration += 1
		var roll = rng.randf()
		#successful roll --> assigns new area to route step
		if roll < RS_weight:
			route_steps[i].areas.push_back(Level.area_points[area_index])
			num_areas_left -= 1
			area_index += 1
		#edge case: force succesful roll if no previous areas
		elif (area_index == 0):
			route_steps[i].areas.push_back(Level.area_points[area_index])
			num_areas_left -= 1
			area_index += 1
		#unsuccesful roll --> assign from previous areas to route step
		else: 
			#TODO: make num_prev_areas relate to the current RS reward pool.
			#idea --> force RS with key items to be revisits, distribute amongst as many areas as key item units
			var num_prev_areas:int = rng.randi_range(1, area_index - new_areas_this_iteration)
			var available_indexes:Array = range(area_index - new_areas_this_iteration)
			for j:int in range(num_prev_areas):
				var index_list_random_index:int = rng.randi_range(0, len(available_indexes)-1)
				var random_index = available_indexes.pop_at(index_list_random_index)
				route_steps[i].areas.push_back(Level.area_points[random_index])
		num_rs_left -= 1
	#display in UI
	ui.display_rs_info()

func step_8(): ##randomly place around areas a point for each relation, one for fast-travel room and one extra for spawn room
	for i:int in len(Level.area_points):
		var current_area:AreaPoint = Level.area_points[i]
		current_area.subpoints.resize(len(current_area.relations) + (2 if i == 1 else 1))
		#spawn points
		spawn_points(current_area.subpoints, Vector2(area_size, area_size))
		current_area.add_subarea_nodes()

func step_9(): ##randomly place around areas a point for each main upgrade, key item unit and side upgrades.
	for current_step:RouteStep in Level.route_steps:
		if current_step.keyset[0] is MainUpgrade:
			var main_upgrade:MainUpgrade = current_step.keyset[0]
			var chosen_area:AreaPoint = current_step.areas[rng.randi_range(0, len(current_step.areas) - 1)]
			var random_pos:Vector2 = Vector2(rng.randf_range(-area_size/2.0,area_size/2.0), rng.randf_range(-area_size/2.0, area_size/2.0))
			var new_point:Point = Point.createNew(random_pos)
			chosen_area.upgrade_pool.push_back(main_upgrade)
			chosen_area.subpoints.push_back(new_point)
		elif current_step.keyset[0] is KeyItem:
			var key_item:KeyItem = current_step.keyset[0]
			for KIU:KeyItemUnit in key_item.kius:
				var chosen_area:AreaPoint = current_step.areas[rng.randi_range(0, len(current_step.areas) - 1)]
				var random_pos = Vector2(rng.randf_range(-area_size/2.0,area_size/2.0), rng.randf_range(-area_size/2.0, area_size/2.0))
				var new_point = Point.createNew(random_pos)
				chosen_area.upgrade_pool.push_back(KIU)
				chosen_area.subpoints.push_back(new_point)
	#add new nodes
	for area:AreaPoint in Level.area_points:
		area.add_subarea_nodes()

func spawn_points(points:Array, pixel_dimensions:Vector2, is_area:bool = false): #Input: Array[Point] (or subclasses)
	for i in range(len(points)):
		#TODO better random procedure
		var random_pos = Vector2(rng.randf_range(-pixel_dimensions.x/2.0,pixel_dimensions.x/2.0), rng.randf_range(-pixel_dimensions.y/2.0, pixel_dimensions.y/2.0))
		var current_point = AreaPoint.createNew(random_pos) if is_area else Point.createNew(random_pos)
		points[i] = current_point

func connect_points(points:Array):
	for i:int in range(len(points)):
		var current_point:Point = points[i]
		compute_point_relations(i)
		current_point.queue_redraw()
	join_stragglers()

#TODO: tweak values
const MIN_ANGULAR_DISTANCE:float = PI/2.5
func compute_point_relations(index:int):
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

func DEBUG_check_RSs():
	for RS:RouteStep in Level.route_steps:
		print('---------------------------------------------------------------')
		print('RS', RS.index, ' with areas: ')
		for area in RS.areas:
			print(area.area_index)

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
