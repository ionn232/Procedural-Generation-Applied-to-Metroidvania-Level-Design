class_name MapGenerator
extends Node2D

@onready var ui: CanvasLayer = $"../UI"

@export var map_size_x:int
@export var map_size_y:int

@export_range (1,25) var number_route_steps:int
@export_range (1,25) var number_of_areas:int
@export_range (0, 9) var number_side_upgrades:int

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

#from center to edge (more like area radiuses)
var area_size:float
var area_size_rooms:int
var area_size_xy:Vector2

const ROOM_SIZE:float = 16.0
const MIN_ANGULAR_DISTANCE:float = PI/3.0 #distance applied to each side, effectively doubled

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
	#area size
	area_size = ((map_size_x+map_size_y)*16/2.0)/float(number_of_areas) #arbitrarily decided
	var w_h_ratio:float = map_size_x/float(map_size_y)
	area_size_xy = Vector2(map_size_x * w_h_ratio, map_size_y / w_h_ratio)
	area_size_rooms = ceil(area_size / 16.0)
	
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
			side_upgrades_left -= 1
	Level.route_steps = route_steps

func _stage_handler(): #TODO: queue point redraws each step instead of whatever is done now
	redraw_all()
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
		10:
			step_10()
		11:
			step_11()
		12:
			step_12()
		13:
			pass
		14:
			pass

func step_1(): ##1: place as many points as the number of areas
	var area_points : Array[AreaPoint] = []
	area_points.resize(number_of_areas)
	spawn_points(area_points, Vector2(map_size_x, map_size_y), true)
	Level.area_points = area_points

func step_2(): ##expand points from centroid and ensure minimum distance
	#calculate centroid
	var centroid : Vector2 = Vector2(0,0)
	for area_point:AreaPoint in Level.area_points:
		centroid += area_point.pos
	centroid.x /= len(Level.area_points)
	centroid.y /= len(Level.area_points)
	#expand areas from centroid
	expand_points(Level.area_points, centroid, 2*area_size, ROOM_SIZE)

func step_3(): ##establish initial area
	var rand_index :int = rng.randi_range(0, number_of_areas - 1)
	Level.initial_area = Level.area_points[rand_index]
	Level.initial_area.set_point_color(Utils.area_colors[0])

func step_4(): ##establish area connections 
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
		#remove next area from elegibility: store progression and backtracking routes
		progression_routes[expanding_area_index].push_back(available_routes[expanding_area_index].pop_at(route_index))
		for current_route_list in available_routes: #TODO: introduce randomness (allow multiple entries to new area)
			current_route_list.erase(new_area)
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
	var max_num_relations:int = -1
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
		elif new_areas_this_iteration == 0: 
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
		current_area.subpoints.resize(len(current_area.relations) + (2 if i == 0 else 1))
		#spawn points
		spawn_points(current_area.subpoints, Vector2(area_size_rooms, area_size_rooms))
		current_area.add_subarea_nodes()

func step_9(): ##randomly place around areas a point for each main upgrade, key item unit and side upgrades.
	for current_step:RouteStep in Level.route_steps:
		#main upgrades
		if current_step.keyset[0] is MainUpgrade:
			var main_upgrade:MainUpgrade = current_step.keyset[0]
			var chosen_area:AreaPoint = current_step.areas[rng.randi_range(0, len(current_step.areas) - 1)]
			var random_pos:Vector2 = Vector2(rng.randf_range(-area_size_rooms/2.0,area_size_rooms/2.0), rng.randf_range(-area_size_rooms/2.0, area_size_rooms/2.0))
			var new_point:Point = Point.createNew(random_pos)
			chosen_area.upgrade_pool.push_back(main_upgrade)
			chosen_area.subpoints.push_back(new_point)
		#key items
		elif current_step.keyset[0] is KeyItem:
			var key_item:KeyItem = current_step.keyset[0]
			for KIU:KeyItemUnit in key_item.kius:
				var chosen_area:AreaPoint = current_step.areas[rng.randi_range(0, len(current_step.areas) - 1)]
				var random_pos = Vector2(rng.randf_range(-area_size_rooms/2.0,area_size_rooms/2.0), rng.randf_range(-area_size_rooms/2.0, area_size_rooms/2.0))
				var new_point = Point.createNew(random_pos)
				chosen_area.upgrade_pool.push_back(KIU)
				chosen_area.subpoints.push_back(new_point)
		#side upgrades
		var rs_side_upgrades:Array[Reward] = current_step.get_side_upgrades()
		for side_upgrade:SideUpgrade in rs_side_upgrades:
			var chosen_area:AreaPoint = current_step.areas[rng.randi_range(0, len(current_step.areas) - 1)]
			var random_pos:Vector2 = Vector2(rng.randf_range(-area_size_rooms/2.0,area_size_rooms/2.0), rng.randf_range(-area_size_rooms/2.0, area_size_rooms/2.0))
			var new_point:Point = Point.createNew(random_pos)
			chosen_area.upgrade_pool.push_back(side_upgrade)
			chosen_area.subpoints.push_back(new_point)
	#add new nodes
	for area:AreaPoint in Level.area_points:
		area.add_subarea_nodes()

func step_10(): ##expand intra-area points
	for current_area:AreaPoint in Level.area_points:
		var intra_area_distance = area_size / float(len(current_area.subpoints))
		expand_points(current_area.subpoints, current_area.pos, 2*intra_area_distance, ROOM_SIZE)

func step_11(): ##assign points as area connectors and establish relation
	for i:int in range(len(Level.area_points)): ##TODO optimize. This currently assigns each relation twice.
		var current_area:AreaPoint = Level.area_points[i]
		for j:int in range(len(current_area.relations)):
			var related_area:AreaPoint = current_area.relations[j]
			#get related area subpoint closest to current area point
			var min_distance:float = INF
			var best_potential_related_connection:Point
			var best_potential_current_connection:Point
			var current_area_pos:Vector2 = current_area.global_position
			for k:int in range(len(related_area.subpoints)):
				var potential_connection:Point = related_area.subpoints[k]
				var potential_connection_pos:Vector2 = potential_connection.global_position
				var distance_sq:float = current_area_pos.distance_to(potential_connection_pos)
				if  distance_sq < min_distance:
					best_potential_related_connection = potential_connection
					min_distance = distance_sq
			#get current area subpoint closest to related area point
			min_distance = INF
			var related_area_pos:Vector2 = related_area.global_position
			for k:int in range(len(current_area.subpoints)):
				var potential_connection:Point = current_area.subpoints[k]
				var potential_connection_pos:Vector2 = potential_connection.global_position
				var distance_sq:float = related_area_pos.distance_to(potential_connection_pos)
				if  distance_sq < min_distance:
					best_potential_current_connection = potential_connection
					min_distance = distance_sq
			
			#replace points for connection points if applicable, assign connection, add to areapoint
			var is_progress:bool = current_area.relation_is_progress[j]
			#TODO: clean this shit up bro
			if (best_potential_current_connection is ConnectionPoint) && (best_potential_related_connection is ConnectionPoint):
				best_potential_current_connection.add_connector_relation(best_potential_related_connection, is_progress)
				best_potential_related_connection.add_connector_relation(best_potential_current_connection, is_progress)
			elif (best_potential_current_connection is ConnectionPoint) && !(best_potential_related_connection is ConnectionPoint):
				var connection_related:ConnectionPoint = ConnectionPoint.createNew(best_potential_related_connection.pos)
				best_potential_current_connection.add_connector_relation(connection_related, is_progress)
				connection_related.add_connector_relation(best_potential_current_connection, is_progress)
				related_area.remove_child(best_potential_related_connection)
				var index:int = related_area.subpoints.find(best_potential_related_connection)
				related_area.subpoints[index] = connection_related
				related_area.add_subarea_nodes()
				best_potential_related_connection.queue_free()
			elif !(best_potential_current_connection is ConnectionPoint) && (best_potential_related_connection is ConnectionPoint):
				var connection_current:ConnectionPoint = ConnectionPoint.createNew(best_potential_current_connection.pos)
				best_potential_related_connection.add_connector_relation(connection_current, is_progress)
				connection_current.add_connector_relation(best_potential_related_connection, is_progress)
				current_area.remove_child(best_potential_current_connection)
				var index:int = current_area.subpoints.find(best_potential_current_connection)
				current_area.subpoints[index] = connection_current
				current_area.add_subarea_nodes()
				best_potential_current_connection.queue_free()
			else:
				var connection_related:ConnectionPoint = ConnectionPoint.createNew(best_potential_related_connection.pos)
				var connection_current:ConnectionPoint = ConnectionPoint.createNew(best_potential_current_connection.pos)
				connection_current.add_connector_relation(connection_related, is_progress)
				current_area.remove_child(best_potential_current_connection)
				var index:int = current_area.subpoints.find(best_potential_current_connection)
				current_area.subpoints[index] = connection_current
				current_area.add_subarea_nodes()
				best_potential_current_connection.queue_free()
				
				connection_related.add_connector_relation(connection_current, is_progress)
				related_area.remove_child(best_potential_related_connection)
				index = related_area.subpoints.find(best_potential_related_connection)
				related_area.subpoints[index] = connection_related
				related_area.add_subarea_nodes()
				best_potential_related_connection.queue_free()
				
		#BUG potencial loop aparte para no influenciar siguientes iteraciones
		#remove points as needed if relations 1:n exist
		var connector_count:int = current_area.subpoints.reduce(func(acc, val): return acc + int(val is ConnectionPoint), 0)
		var connector_pool:int = len(current_area.relations)
		var points_to_remove:int = connector_pool - connector_count
		for j:int in range(points_to_remove):
			var index:int = 0 #in case first point is connector
			while true: #TODO fix cardinal sin
				var removal_candidate = current_area.subpoints[index]
				if !(removal_candidate is ConnectionPoint):
					current_area.subpoints.pop_at(index)
					current_area.remove_child(removal_candidate)
					removal_candidate.queue_free()
					break
				index += 1

func step_12(): ##establish relations between area subpoints
	for current_area:AreaPoint in Level.area_points:
		connect_points(current_area.subpoints)

func spawn_points(points:Array, pixel_dimensions:Vector2, is_area:bool = false): #Input: Array[Point] (or subclasses)
	for i in range(len(points)):
		#TODO better random procedure
		var random_pos = Vector2(rng.randf_range(-pixel_dimensions.x/2.0,pixel_dimensions.x/2.0), rng.randf_range(-pixel_dimensions.y/2.0, pixel_dimensions.y/2.0))
		var current_point = AreaPoint.createNew(random_pos) if is_area else Point.createNew(random_pos)
		points[i] = current_point

func expand_points(points:Array, center:Vector2, min_distance:float, expansion_factor:float = 0):
	#expand areas from center
	for current_point:Point in points:
		var center_to_area:Vector2 = current_point.global_position - center
		current_point.update_position(current_point.pos + center_to_area * expansion_factor) 
	#expand areas from each other
	#TODO: tweak parameters
	var map_boundary_x:float = map_size_x*16/2.0
	var map_boundary_y:float = map_size_y*16/2.0
	var clear = false
	var count:int = 0
	while (!clear):
		clear = true
		count += 1
		if (count == 1000):
			print('WARNING! not enough space to correctly expand points')
			print('results may be poor, please tweak parameters')
			break
		for current_point:Point in points:
			#keep point inside grid (border mirroring)
			if abs(current_point.global_position.x) > map_boundary_x:
				var point_to_reflection:Vector2 = Vector2(1, 0) * (2 * (sign(current_point.global_position.x) * map_boundary_x - current_point.global_position.x))
				current_point.update_position(current_point.pos + point_to_reflection)
				clear = false
			elif abs(current_point.global_position.y) > map_boundary_y:
				var point_to_reflection:Vector2 = Vector2(0, 1) * (2 * (sign(current_point.global_position.y) * map_boundary_y - current_point.global_position.y))
				current_point.update_position(current_point.pos + point_to_reflection)
				clear = false
			#check distance to other points
			for second_point:Point in points:
				if current_point == second_point: continue
				var distance:float = current_point.global_position.distance_to(second_point.global_position)
				#move points in conflict to current
				if (distance <= min_distance):
					var current_to_second:Vector2 = current_point.global_position.direction_to(second_point.global_position)
					second_point.update_position(second_point.pos + current_to_second * (min_distance - distance + 0.1)) #DO NOT REMOVE THE 0.1
					clear = false

func connect_points(points:Array): #BUG: sometimes isolated segments are formed
	for i:int in range(len(points)):
		var current_point:Point = points[i]
		compute_point_relations(points, i)
	clean_islands(points)

func compute_point_relations(points:Array, index:int):
	var angles:Array = [] #type: float | null
	var angle_candidates:Array = [] #type: float | null
	angles.resize(len(points))
	angle_candidates.resize(len(points))
	var current_point:Point = points[index]
	#record relative angles
	for j:int in range(len(points)):
		var second_point:Point = points[j]
		if current_point == second_point: continue
		var angle = current_point.global_position.angle_to_point(second_point.global_position)
		angles[j] = angle
	#import existing relations for computation, remove from relation arrays
	for existing_relation:Point in current_point.relations:
		var existing_index:int = points.find(existing_relation)
		angle_candidates[existing_index] = angles[existing_index]
		existing_relation.relations.erase(current_point)
	current_point.relations.resize(0)
	#compare angles and distances, decide point relations
	decide_relations(points, current_point, angles, angle_candidates)
	#establish relations between current point and each final candidate
	for j:int in range(len(points)):
		var final_candidate = angle_candidates[j] 
		if !final_candidate: continue
		if index==j: continue
		current_point.relations.push_back(points[j])
		points[j].relations.push_back(current_point)
		#if j < index: compute_point_relations(points, j)
		clear_incompatible_relations(points[j])

func decide_relations(points:Array, current_point:Point, angles:Array, angle_candidates:Array):
	#var max_distance :float = (map_size_x + map_size_y)*16 / float(number_of_areas * 0.1) #TODO: tweak n use this maybe
	var j:int = -1
	while j < len(points)-1:
		j += 1
		var second_point_angle = angles[j]
		if !second_point_angle: continue
		#check if point is suitable
		var suitable = true
		var k:int = -1
		while k < len(points)-1:
			k += 1
			var existing_relation_angle = angle_candidates[k]
			if j==k: continue
			if !existing_relation_angle: continue 
			if abs(second_point_angle - existing_relation_angle) < MIN_ANGULAR_DISTANCE: 
				suitable = false
				var distance_existing:float = current_point.pos.distance_squared_to(points[k].global_position)
				var distance_new:float = current_point.pos.distance_squared_to(points[j].global_position)
				if distance_new < distance_existing:
					angle_candidates[k] = null
					angle_candidates[j] = angles[j]
		if suitable:
			angle_candidates[j] = second_point_angle #TODO: introduce randomness to make it more interesting maybe

func join_stragglers(points:Array):
	for current_point:Point in points:
		if len(current_point.relations) == 0:
			print('straggling point: ', points.find(current_point))
			var min_dist:float = INF
			var closest_point_index:int
			for i:int in range(len(points)):
				var second_point:Point = points[i]
				if current_point == second_point: continue
				var distance_sq:float = current_point.global_position.distance_squared_to(second_point.global_position)
				if distance_sq < min_dist:
					min_dist = distance_sq
					closest_point_index = i
			current_point.relations.push_back(points[closest_point_index])
			points[closest_point_index].relations.push_back(current_point)

func clean_islands(points:Array):
	var remaining_points:Array = points.duplicate() #Array[Points]
	var point_islands:Array[Array] #Array[Array[Point]]
	
	#get all point islands
	for i:int in range(len(points)):
		var current_point:Point = points[i]
		if !(remaining_points.has(current_point)): continue
		print('base call')
		var island:Array[Point]
		get_island(island, current_point)
		for isl_point:Point in island:
			remaining_points.erase(isl_point)
		point_islands.push_back(island)
	
	#connect one island to the closest point of another until no islands left
	while len(point_islands) > 1:
		var min_dist:float = INF
		var best_local_candidate:Point
		var best_second_candidate:Point
		for i:int in range(len(point_islands[0])):
			var current_island_candidate:Point = point_islands[0][i]
			for j:int in range(len(point_islands)):
				if j==0: continue
				var second_island:Array[Point] = point_islands[j]
				for k:int in range(len(second_island)):
					var second_island_candidate:Point = second_island[k]
					var dist_sq:float = current_island_candidate.global_position.distance_squared_to(second_island_candidate.global_position)
					if dist_sq < min_dist:
						best_local_candidate = current_island_candidate
						best_second_candidate = second_island_candidate
						min_dist = dist_sq
		best_local_candidate.relations.push_back(best_second_candidate)
		best_second_candidate.relations.push_back(best_local_candidate)
		point_islands.pop_front() #TODO better memory management: maybe have another fucking for loop who cares at this point

func get_island(island_points:Array[Point], current_point:Point):
	if island_points.has(current_point): return
	island_points.push_back(current_point)
	for i:int in range(len(current_point.relations)):
		var relation = current_point.relations[i]
		get_island(island_points, relation)

func clear_incompatible_relations(point:Point): #iterate over point relations. remove relation if it conflicts with any previous one
	var relation_angles:Array[float]
	relation_angles.resize(len(point.relations))
	var relations_to_remove:Array[Point]
	for i:int in range(len(point.relations)):
		var relation = point.relations[i]
		var angle = point.global_position.angle_to_point(relation.global_position)
		relation_angles[i] = angle
		for j:int in range(i):
			var previous_relation = point.relations[j]
			if previous_relation in relations_to_remove: continue
			var previous_relation_angle = relation_angles[j]
			if abs(previous_relation_angle - angle) < MIN_ANGULAR_DISTANCE: 
				relations_to_remove.push_back(relation)
				break
	for deprecated_relation:Point in relations_to_remove:
		point.relations.erase(deprecated_relation)
		deprecated_relation.relations.erase(point)

func redraw_all():
	queue_redraw()
	for area:AreaPoint in Level.area_points:
		area.queue_redraw()
		for subpoint:Point in area.subpoints:
			subpoint.queue_redraw()

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

const font = preload("res://data/upheavtt.ttf")
func _draw():
	for current_area:AreaPoint in Level.area_points:
		draw_circle(current_area.pos, area_size, Color.BLACK, false)
		var intra_area_distance = area_size / float(len(current_area.subpoints))
		
		for related_area:AreaPoint in current_area.relations:
			var angle = current_area.global_position.angle_to_point(related_area.global_position)
			var direction = Vector2(1,0)
			var angle_1 = direction.rotated(angle + MIN_ANGULAR_DISTANCE)
			var angle_2 = direction.rotated(angle - MIN_ANGULAR_DISTANCE)
			draw_line(current_area.position, current_area.position + angle_1 * 100, Color(0,0,0,0.3), 2, false)
			draw_line(current_area.position, current_area.position + angle_2 * 100, Color(0,0,0,0.3), 2, false)
		
		for subpoint:Point in current_area.subpoints:
			draw_circle(subpoint.global_position, intra_area_distance, Color.BLACK, false)
			
			var debug_index = current_area.subpoints.find(subpoint)
			draw_string(font , subpoint.global_position + Vector2(0,20), str(debug_index), 0, -1, 16, Color.BLACK)
			
			for related_point:Point in subpoint.relations:
				var angle = subpoint.global_position.angle_to_point(related_point.global_position)
				var direction = Vector2(1,0)
				var angle_1 = direction.rotated(angle + MIN_ANGULAR_DISTANCE)
				var angle_2 = direction.rotated(angle - MIN_ANGULAR_DISTANCE)
				draw_line(subpoint.global_position, subpoint.global_position + angle_1 * 50, Color(0,0,0,0.8), 1, false)
				draw_line(subpoint.global_position, subpoint.global_position + angle_2 * 50, Color(0,0,0,0.8), 1, false)
