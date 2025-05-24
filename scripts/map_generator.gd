class_name MapGenerator
extends Node2D

@onready var ui: CanvasLayer = $"../UI"

@export var map_size_x:int
@export var map_size_y:int

@export_range (1,25) var number_route_steps:int
@export_range (1,25) var number_of_areas:int
@export_range (0, 9) var number_side_upgrades:int
@export_range (0, 50) var number_equipment_items:int
@export_range (0, 50) var number_collectibles:int
@export_range (0, 50) var number_stat_upgrades:int
@export_range (0.1,5.0) var area_size_multiplier:float


#area size DIAMETER
var area_size:float
var area_size_rooms:int
var area_size_xy:Vector2
#TODO: track intra_area_size globally somehow, keep

const ROOM_SIZE:float = 16.0
const MIN_ANGULAR_DISTANCE:float = PI/3.0 #distance applied to each side, effectively doubled
var draw_angles:bool = false

func _ready() -> void: ##level, map initializations // rng seeding
	ui.stage_changed.connect(_stage_handler.bind())
	Utils.rng.seed = hash("2")
	#initialize map
	Level.map_size_x = map_size_x
	Level.map_size_y = map_size_y
	var main_map:Map = Map.new()
	main_map.initialize_map()
	Level.map = main_map
	
	#TODO tweak and separate x, y
	#area size (DIAMETER)
	area_size = ((map_size_x+map_size_y)*16/2.0)*area_size_multiplier/float(number_of_areas) #arbitrarily decided
	var w_h_ratio:float = map_size_x/float(map_size_y)
	area_size_xy = Vector2(map_size_x * w_h_ratio, map_size_y / w_h_ratio)
	area_size_rooms = ceil(area_size / 16.0)
	Level.num_areas = number_of_areas
	Level.num_route_steps = number_route_steps
	
	#load reward pool
	RewardPool.import_reward_pool()
	#distribute rewards amongst route steps #TODO: make a separate step
	var route_steps:Array[RouteStep]
	route_steps.resize(number_route_steps)
	var keyset_indexes:Array = range(len(RewardPool.keyset))
	var side_indexes:Array = range(len(RewardPool.side_upgrades))
	var RS_item_weight:float
	var side_upgrades_left:int = number_side_upgrades
	var equipment_items_left:int = number_equipment_items
	var collectibles_left:int = number_collectibles
	var stat_upgrades_left:int = number_stat_upgrades
	var roll:float
	for i:int in range(number_route_steps):
		route_steps[i] = RouteStep.createNew(i)
		#assign RS main key
		var indexes_random_index:int = Utils.rng.randi_range(0, len(keyset_indexes)-1)
		route_steps[i].add_key(RewardPool.keyset[keyset_indexes.pop_at(indexes_random_index)])
		#assign side upgrades
		RS_item_weight = side_upgrades_left / float(number_route_steps - i)
		while RS_item_weight > 1.0:
			indexes_random_index = Utils.rng.randi_range(0, len(side_indexes)-1)
			route_steps[i].add_reward(RewardPool.side_upgrades[side_indexes.pop_at(indexes_random_index)])
			side_upgrades_left -= 1
			RS_item_weight -= 1.0
		roll = Utils.rng.randf()
		if roll < RS_item_weight:
			indexes_random_index = Utils.rng.randi_range(0, side_upgrades_left - 1)
			route_steps[i].add_reward(RewardPool.side_upgrades[side_indexes.pop_at(indexes_random_index)])
			side_upgrades_left -= 1
		#assign equipment
		RS_item_weight = equipment_items_left / float(number_route_steps - i)
		while RS_item_weight > 1.0:
			route_steps[i].add_reward(RewardPool.equipment[number_equipment_items - equipment_items_left])
			equipment_items_left -= 1
			RS_item_weight -= 1.0
		roll = Utils.rng.randf()
		if roll < RS_item_weight:
			route_steps[i].add_reward(RewardPool.equipment[number_equipment_items - equipment_items_left])
			equipment_items_left -= 1
		#assign collectibles
		RS_item_weight = collectibles_left / float(number_route_steps - i)
		while RS_item_weight > 1.0:
			route_steps[i].add_reward(RewardPool.collectibles[number_collectibles - collectibles_left])
			collectibles_left -= 1
			RS_item_weight -= 1.0
		roll = Utils.rng.randf()
		if roll < RS_item_weight:
			route_steps[i].add_reward(RewardPool.collectibles[number_collectibles - collectibles_left])
			collectibles_left -= 1
		#assign stat upgrades
		RS_item_weight = stat_upgrades_left / float(number_route_steps - i)
		while RS_item_weight > 1.0:
			route_steps[i].add_reward(RewardPool.stat_upgrades[number_stat_upgrades - stat_upgrades_left])
			stat_upgrades_left -= 1
			RS_item_weight -= 1.0
		roll = Utils.rng.randf()
		if roll < RS_item_weight:
			route_steps[i].add_reward(RewardPool.stat_upgrades[number_stat_upgrades - stat_upgrades_left])
			stat_upgrades_left -= 1
	#store info
	Level.route_steps = route_steps


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
			step_13()
		14:
			step_14()
		15:
			step_15()
		16:
			step_16()
		17:
			step_17()
		18:
			step_18()
		19:
			step_19()
		20:
			step_20()
	redraw_all()


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
	expand_points(Level.area_points, centroid, area_size, ROOM_SIZE)

func step_3(): ##establish initial area
	var rand_index :int = Utils.rng.randi_range(0, number_of_areas - 1)
	Level.initial_area = Level.area_points[rand_index]
	Level.initial_area.set_point_color(Utils.area_colors[0])

func step_4(): ##establish area connections 
	connect_points(Level.area_points)

func step_5(): ##designate area order by expanding from initial area, designate areas as progression or backtracking
	#struct inits
	var ordered_areas:Array[AreaPoint] = []
	var available_routes:Array[Array] #Array of [origin: AreaPoint, routes: [AreaPoint]]
	var progression_routes:Array[Array] #Array of [origin: AreaPoint, routes: [AreaPoint]]
	ordered_areas.resize(number_of_areas)
	available_routes.resize(number_of_areas)
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
			expanding_area_index = Utils.rng.randi_range(0, i-1)
			if len(available_routes[expanding_area_index]) == 0: proceed = false #area has no routes left to expand, reroll
		#roll next area
		var route_index:int = Utils.rng.randi_range(0, len(available_routes[expanding_area_index])-1)
		var new_area:AreaPoint = available_routes[expanding_area_index][route_index]
		#add new area to final lineup
		ordered_areas[i] = new_area
		new_area.set_point_color(Utils.area_colors[i])
		new_area.area_index = i
		new_area.relation_is_progress.resize(len(new_area.relations))
		new_area.relation_is_progress.fill(false) #ts redundant, it's the default value
		#remove next area from elegibility: store progression and backtracking routes
		progression_routes[expanding_area_index].push_back(available_routes[expanding_area_index].pop_at(route_index))
		for current_route_list in available_routes: #TODO: introduce randomness (allow multiple entries to new area) IF YOU DO THIS REWORK CODE FOR get_area_start_points()
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
		var roll = Utils.rng.randf()
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
			var num_prev_areas:int = Utils.rng.randi_range(1, area_index - new_areas_this_iteration)
			var available_indexes:Array = range(area_index - new_areas_this_iteration)
			for j:int in range(num_prev_areas):
				var index_list_random_index:int = Utils.rng.randi_range(0, len(available_indexes)-1)
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
			var chosen_area:AreaPoint = current_step.areas[Utils.rng.randi_range(0, len(current_step.areas) - 1)]
			var random_pos:Vector2 = Vector2(Utils.rng.randf_range(-area_size_rooms/2.0,area_size_rooms/2.0), Utils.rng.randf_range(-area_size_rooms/2.0, area_size_rooms/2.0))
			var new_point:Point = Point.createNew(random_pos)
			chosen_area.reward_pool.push_back(main_upgrade)
			chosen_area.subpoints.push_back(new_point)
		#key items
		elif current_step.keyset[0] is KeyItem:
			var key_item:KeyItem = current_step.keyset[0]
			for KIU:KeyItemUnit in key_item.kius:
				var chosen_area:AreaPoint = current_step.areas[Utils.rng.randi_range(0, len(current_step.areas) - 1)]
				var random_pos = Vector2(Utils.rng.randf_range(-area_size_rooms/2.0,area_size_rooms/2.0), Utils.rng.randf_range(-area_size_rooms/2.0, area_size_rooms/2.0))
				var new_point = Point.createNew(random_pos)
				chosen_area.reward_pool.push_back(KIU)
				chosen_area.subpoints.push_back(new_point)
		#side upgrades
		var rs_side_upgrades:Array[Reward] = current_step.get_side_upgrades()
		for side_upgrade:SideUpgrade in rs_side_upgrades:
			var chosen_area:AreaPoint = current_step.areas[Utils.rng.randi_range(0, len(current_step.areas) - 1)]
			var random_pos:Vector2 = Vector2(Utils.rng.randf_range(-area_size_rooms/2.0,area_size_rooms/2.0), Utils.rng.randf_range(-area_size_rooms/2.0, area_size_rooms/2.0))
			var new_point:Point = Point.createNew(random_pos)
			chosen_area.reward_pool.push_back(side_upgrade)
			chosen_area.subpoints.push_back(new_point)
	#add new nodes
	for area:AreaPoint in Level.area_points:
		area.add_subarea_nodes()

func step_10(): ##expand intra-area points
	for current_area:AreaPoint in Level.area_points:
		var intra_area_distance = area_size / float(len(current_area.subpoints))
		expand_points(current_area.subpoints, current_area.pos, intra_area_distance, ROOM_SIZE)

func step_11(): ##assign points as area connectors and establish relation
	for i:int in range(len(Level.area_points)):
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

func step_13(): ##assign points as fast-travel rooms
		for j:int in range(len(Level.area_points)):
			#identify unassigned subpoint with most relations
			var current_area:AreaPoint = Level.area_points[j]
			var best_candidate:Point
			var max_num_relations:int = -1
			for k:int in range(len(current_area.subpoints)):
				var current_candidate:Point = current_area.subpoints[k]
				if !(current_candidate.is_generic): continue
				var num_relations:int = len(current_candidate.relations) #TODO: greater weight to generic points than connector points.
				if num_relations > max_num_relations:
					best_candidate = current_candidate
					max_num_relations = num_relations
			#create point and add to area
			var fast_travel_point:FastTravelPoint = FastTravelPoint.createNew(best_candidate.position, best_candidate)
			var replace_index:int = current_area.subpoints.find(best_candidate)
			current_area.subpoints[replace_index] = fast_travel_point
			#manage memory and scene tree
			current_area.remove_child(best_candidate)
			best_candidate.queue_free()
			current_area.add_subarea_nodes()
			# prepare for hub zone if applicable
			if current_area.has_hub:
				var intra_area_distance = area_size / float(len(current_area.subpoints))
				#TODO 1: flat, not scaling. Behaves weird for large areas.
				ensure_min_dist_around(fast_travel_point, current_area.subpoints, intra_area_distance*1.5)

func step_14(): ##assign points as spawn point, side upgrades, main upgrades and key item units
	#identify protected points for each area beyond initial
	for current_area:AreaPoint in Level.area_points:
		if current_area.area_index == 0: continue #spawn point placement procedure takes care of the problem
		set_protected_points(current_area)
	#assign points
	var spawn_placed:bool = false
	for i:int in range(len(Level.route_steps)):
		var current_step:RouteStep = Level.route_steps[i]
		var step_keyset_flat:Array = current_step.keyset.reduce(
			func(acc:Array, val): 
			if val is MainUpgrade:
				return acc + [val]
			if val is KeyItem:
				return acc + val.kius 
			, [])
		for j:int in range(len(current_step.areas)):
			var current_area:AreaPoint = current_step.areas[j]
			#Array[MainUpgrade || KeyItemUnit]
			var area_step_keyset:Array = get_intersection(step_keyset_flat, current_area.reward_pool)
			#Array[SideUpgrade]
			var area_step_SUs:Array = get_intersection(current_step.reward_pool, current_area.reward_pool).filter(func(val): return val is SideUpgrade)
			var area_step_points:Array[Point] = get_area_step_points(current_area, len(area_step_keyset) + len(area_step_SUs) + (1 if !spawn_placed else 0), spawn_placed)
			
			#assign spawn point TODO:fuse with keyset points procedure (its the same)
			if !spawn_placed:
				var best_candidate:Point = null
				var max_steps_to_crossroads:int = -1
				for l:int in range(len(area_step_points)):
					var current_candidate:Point = area_step_points[l]
					if !(current_candidate.is_generic): continue
					var crossroad_step_distance:int = steps_to_crossroads(current_candidate)
					if crossroad_step_distance > max_steps_to_crossroads:
						best_candidate = current_candidate
						max_steps_to_crossroads = crossroad_step_distance
				#create point and add to area
				var spawn_point = SpawnPoint.createNew(best_candidate.position, best_candidate)
				var replace_index:int = current_area.subpoints.find(best_candidate)
				spawn_point.associated_step = current_step
				current_area.subpoints[replace_index] = spawn_point
				area_step_points.erase(best_candidate)
				#manage memory and scene tree
				current_area.remove_child(best_candidate)
				best_candidate.queue_free()
				current_area.add_subarea_nodes()
				spawn_placed = true
			
			#assign keyset points
			for k:int in range(len(area_step_keyset)):
				var current_reward:Reward = area_step_keyset[k]
				#identify most isolated unassigned subpoint for major rewards
				if current_reward is MainUpgrade || current_reward is KeyItemUnit:
					var best_candidate:Point = null
					var max_steps_to_crossroads:int = -1
					for l:int in range(len(area_step_points)):
						var current_candidate:Point = area_step_points[l]
						if !(current_candidate.is_generic): continue
						var crossroad_step_distance:int = steps_to_crossroads(current_candidate)
						if crossroad_step_distance > max_steps_to_crossroads:
							best_candidate = current_candidate
							max_steps_to_crossroads = crossroad_step_distance
					#create point and add to area
					var key_point:Point
					if current_reward is MainUpgrade:
						key_point = MainUpgradePoint.createNew(best_candidate.position, best_candidate)
						key_point.set_data(current_reward, current_step)
					elif current_reward is KeyItemUnit:
						key_point = KeyItemUnitPoint.createNew(best_candidate.position, best_candidate)
						key_point.set_data(current_reward.key,current_reward, current_step)
					key_point.associated_step = current_step
					check_protect_point(best_candidate, key_point, current_area, area_step_points)
			#assign any point for side upgrades (only points left for this area-step)
			for k:int in range(len(area_step_SUs)):
				var generic_point:Point = area_step_points[k]
				var SU_reward:Reward = area_step_SUs[k]
				var SU_point:SideUpgradePoint = SideUpgradePoint.createNew(generic_point.position, generic_point)
				SU_point.set_data(SU_reward, current_step)
				SU_point.associated_step = current_step
				check_protect_point(generic_point, SU_point, current_area)
	
	#necessary computations for next steps
	var current_area_index:int = -1
	for current_step:RouteStep in Level.route_steps:
		for current_area:AreaPoint in current_step.areas:
			if current_area.area_index > current_area_index:
				current_area_index = current_area.area_index
				for subpoint:Point in current_area.subpoints:
					#allocate memory for point relation tracking
					subpoint.relation_is_mapped.resize(len(subpoint.relations))
					subpoint.relation_is_mapped.fill(false) #TODO this is redundant ?
					#assign step indexes for connector points and fast travel points
					if (subpoint is FastTravelPoint):
						var min_neighbor_step_index = min_neighbor_step_index(subpoint)
						subpoint.associated_step = Level.route_steps[min_neighbor_step_index]
					elif (subpoint is ConnectionPoint):
						subpoint.area_relation_is_mapped.resize(len(subpoint.area_relations))
						subpoint.area_relation_is_mapped.fill(false) #TODO this is redundant ?
						var min_neighbor_step_index = min_neighbor_step_index(subpoint)
						subpoint.associated_step = Level.route_steps[min_neighbor_step_index]

func step_15(): ##Place rooms for main upgrades, keyset units, side upgrades, area connectors and spawn room
	for i:int in range(len(Level.area_points)):
		var current_area:AreaPoint = Level.area_points[i]
		for j:int in range(len(current_area.subpoints)):
			var current_point:Point = current_area.subpoints[j]
			var room_position:Vector2i = Utils.world_pos_to_room(current_point.global_position)
			var room_dimensions:Vector2i = Vector2i(Utils.rng.randi_range(1, 3), Utils.rng.randi_range(1, 3)) #TODO discriminate by room type
			#reroll size to avoid room superposition
			while !Room.canCreate(Vector2i(room_position.x - room_dimensions.x/2, room_position.y - room_dimensions.y/2), room_dimensions, current_point):
				room_dimensions = Vector2i(Utils.rng.randi_range(1, 3), Utils.rng.randi_range(1, 3)) #TODO discriminate by room type
				room_position = Utils.world_pos_to_room(current_point.global_position)
			var new_room:Room = Room.createNew(Vector2i(room_position.x - room_dimensions.x/2, room_position.y - room_dimensions.y/2), current_area.area_index, current_point.associated_step.index , room_dimensions, current_point)
			new_room.createRoomMUs()
			current_point.associated_room = new_room
			var random_room_mu:MU = get_random_MU(new_room)
			
			match(current_point):
				_ when current_point is MainUpgradePoint:
					random_room_mu.add_reward(current_point.key_value)
					Level.keyset_rooms.push_back(new_room)
				_ when current_point is KeyItemUnitPoint:
					random_room_mu.add_reward(current_point.key_unit_value)
					Level.keyset_rooms.push_back(new_room)
				_ when current_point is SideUpgradePoint:
					random_room_mu.add_reward(current_point.key_value)
				_ when current_point is SpawnPoint:
					random_room_mu.is_spawn = true
				_ when current_point is FastTravelPoint:
					random_room_mu.is_fast_travel = true

func step_16(): ##Place hub zone rooms
	var hub_area:AreaPoint = Level.area_points.filter(func(val:AreaPoint): return val.has_hub)[0]
	var hub_position:Vector2 = Utils.world_pos_to_room(hub_area.subpoints.filter(func(val:Point): return val is FastTravelPoint)[0].global_position)
	var hub_room_1:Room = Level.map.MUs[hub_position.x][hub_position.y].parent_room
	#use existing room if there is space
	if hub_room_1.room_size.x * hub_room_1.room_size.y >= 3:
		var shop_mu:MU = get_free_MU(hub_room_1)
		shop_mu.is_shop = true
		var save_mu:MU = get_free_MU(hub_room_1)
		save_mu.is_save = true
	#create and use new 2*2 room
	else:
		var rand_direction:Utils.direction
		var rand_direction_vec:Vector2i 
		var new_room_pos:Vector2i
		var new_room_dimensions:Vector2i 
		#avoid superposition
		while !Room.canCreate(new_room_pos, new_room_dimensions):
			rand_direction = Utils.rng.randi_range(0, 3)
			rand_direction_vec = Utils.direction_to_vec2i(rand_direction)
			new_room_dimensions = Vector2i(2,2)
			if rand_direction_vec.x < 0 || rand_direction_vec.y < 0:
				new_room_pos = hub_room_1.grid_pos + rand_direction_vec * new_room_dimensions
			else:
				new_room_pos = hub_room_1.grid_pos + rand_direction_vec * hub_room_1.room_size
		var hub_room_2:Room = Room.createNew(new_room_pos, hub_area.area_index, hub_room_1.step_index , new_room_dimensions)
		hub_room_2.createRoomMUs()
		var shop_mu:MU = get_free_MU(hub_room_2)
		shop_mu.is_shop = true
		var save_mu:MU = get_free_MU(hub_room_2)
		save_mu.is_save = true
		connect_adjacent_rooms(hub_room_1, hub_room_2)

func step_17(): ##Map out connections
	#get step-area points
	for i:int in range(len(Level.route_steps)):
		var current_step:RouteStep
		current_step = Level.route_steps[i]
		var previous_step_keyset = (Level.route_steps[i-1] if i>0 else null)
		for j:int in range(len(current_step.areas)):
			#map out subpoint connections for each area
			var current_area:AreaPoint = current_step.areas[j]
			var area_step_points:Array = current_area.subpoints.filter(func(val:Point): return val.associated_step == current_step )
			for current_point:Point in area_step_points:
				var current_point_room:Room = current_point.associated_room
				#gate adjacent rooms to avoid sequence breaking
				gate_adjacent_rooms(current_point_room)
				#intra-area connections, only to those of current or lower steps for better map results
				for k:int in range(len(current_point.relations)):
					var relation:Point = current_point.relations[k]
					if relation.associated_step.index <= current_point.associated_step.index:
						var relation_room:Room = relation.associated_room
						if !current_point.relation_is_mapped[k]:
							connect_rooms(current_point.associated_room, relation_room)
							current_point.relation_is_mapped[k] = true
							relation.relation_is_mapped[relation.relations.find(current_point)] = true
				#inter-area connections, only those of current step or lower
				if current_point is ConnectionPoint:
					for k:int in range(len(current_point.area_relations)):
						var area_relation:Point = current_point.area_relations[k]
						if area_relation.associated_step.index <= current_point.associated_step.index:
							var relation_room:Room = area_relation.associated_room
							if !current_point.area_relation_is_mapped[k]:
								connect_rooms(current_point.associated_room, relation_room, current_point.area_relation_is_progress[k])
								current_point.area_relation_is_mapped[k] = true
								area_relation.area_relation_is_mapped[area_relation.area_relations.find(current_point)] = true

func step_18(): ##Add save points
	var save_distance:int
	var save_room:Room
	for starting_room:Room in Level.keyset_rooms:
		save_distance = Utils.rng.randi_range(1, 5)
		save_room = dfs_get_room_at_dist(starting_room, save_distance)
		get_random_MU(save_room).is_save = true

func step_19(): ##Extrude keyset points 
	#ascending order to avoid timeouts
	var test1 = Level.trap_rooms
	var test2 = Level.keyset_rooms
	for step:RouteStep in Level.route_steps:
		for current_room:Room in Level.keyset_rooms:
			if current_room.step_index == step.index && !(current_room.is_trap):
				extrude_reward_room(current_room)

func step_20(): ##Distribute minor rewards
	pass

func dfs_get_room_at_dist(room:Room, distance:int, seen_rooms:Array[Room] = []) -> Room:
	seen_rooms.push_back(room)
	var next_room:Room
	#base case
	if distance == 0:
		return room
	#recursive case
	else:
		var min_index = INF
		for mu:MU in room.room_MUs:
			for direction:Utils.direction in range(4):
				if mu.borders[direction] == Utils.border_type.LOCKED_DOOR:
					next_room = Level.map.get_mu_at(mu.grid_pos + Utils.direction_to_vec2i(direction)).parent_room
					if seen_rooms.has(next_room): continue
					elif next_room.step_index > room.step_index: continue
					next_room = dfs_get_room_at_dist(next_room, distance-1, seen_rooms)
					if next_room != null: return next_room
		#dead end
		return null

func extrude_reward_room(room:Room): #TODO: cases where there are no available rooms
	var number_of_extrusions:int = Utils.rng.randi_range(1,4)
	var adjacent_MU:MU
	var adjacent_pos:Vector2i
	var current_room:Room = room
	var prev_extruded_room:Room
	#for room extrusion
	var available_positions:Array[Vector2i]
	var position_directions:Array[Utils.direction]
	#if room cant be extruded
	var previous_rooms:Array[Room]
	var previous_room_directions:Array[Utils.direction]
	var current_reward:Reward
	for i:int in range(number_of_extrusions):
		previous_rooms.clear()
		previous_room_directions.clear()
		available_positions.clear()
		position_directions.clear()
		#get extruded room candidates
		for room_mu:MU in current_room.room_MUs: #TODO optimization iterate just border MUs not all
			#check adjacent positions for each MU
			if len(room_mu.rewards) > 0:
				current_reward = room_mu.rewards[0]
				room_mu.rewards.erase(current_reward)
			for direction:Utils.direction in range(4):
				adjacent_pos = room_mu.grid_pos + Utils.direction_to_vec2i(direction)
				if !Utils.is_pos_inside_map(adjacent_pos):
					continue
				adjacent_MU = Level.map.get_mu_at(adjacent_pos)
				if adjacent_MU == null:
					available_positions.push_back(adjacent_pos)
					position_directions.push_back(direction)
				elif (adjacent_MU.parent_room.step_index <= room.step_index) && room_mu.borders[direction] == Utils.border_type.LOCKED_DOOR:
					previous_rooms.push_back(adjacent_MU.parent_room)
					previous_room_directions.push_back(direction)
		if !current_reward: print('ERROR: no reward selected!')
		#place boss in existing room if one can't be created, make existing entrance one-directional
		if len(available_positions)==0:
			prev_extruded_room = current_room
			if current_reward is MainUpgrade:
				for j:int in range(len(previous_rooms)):
					var gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.ONE_WAY, Utils.opposite_direction(previous_room_directions[j]))
					connect_adjacent_rooms(current_room, previous_rooms[j], gate)
			#no more extrusions possible
			break
		else:
			#select room amongst candidates
			var random_index:int = Utils.rng.randi_range(0, len(available_positions) - 1)
			var selected_position:Vector2i = available_positions[random_index]
			var selected_direction:Utils.direction = position_directions[random_index]
			var direction_vec = Utils.direction_to_vec2i(selected_direction)
			var room_dimensions:Vector2i = Vector2i(1,1) if i == number_of_extrusions - 1 else Vector2i(Utils.rng.randi_range(1, 2),Utils.rng.randi_range(1, 2)) 
			var position_aux:Vector2i = selected_position
			#create new room
			while !Room.canCreate(position_aux, room_dimensions):
				room_dimensions = Vector2i(Utils.rng.randi_range(1, 2), Utils.rng.randi_range(1, 2))
				if direction_vec.x < 0 || direction_vec.y < 0:
					position_aux = selected_position - (room_dimensions - Vector2i(1, 1))
				else:
					position_aux = selected_position
			prev_extruded_room = current_room
			current_room = Room.createNew(position_aux, room.area_index, room.step_index, room_dimensions)
			current_room.createRoomMUs()
			#connect
			var gate:LockedDoor 
			if current_reward is MainUpgrade && i == number_of_extrusions-1:
				gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.ONE_WAY, selected_direction)
			else:
				gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY)
			connect_adjacent_rooms(prev_extruded_room, current_room, gate)
	#set previous room as boss room
	current_room.step_index = room.step_index+1
	prev_extruded_room.is_trap = true
	#set reward in new room
	get_free_MU(current_room).add_reward(current_reward)
	#set boss category
	var mu:MU 
	if prev_extruded_room.room_size.x > 1 || prev_extruded_room.room_size.y > 1: mu = get_free_MU(prev_extruded_room)
	else: mu = prev_extruded_room.room_MUs[0]
	var is_major_boss:bool
	if current_reward is MainUpgrade:
		is_major_boss = true
	elif current_reward is KeyItemUnit:
		is_major_boss = false
	else:
		print('ERROR: invalid reward')
	mu.is_major_boss = is_major_boss
	mu.is_minor_boss = !is_major_boss
	#make upgrade room exit route and loop back to fast-travel area
	if current_reward is MainUpgrade:
		var area:AreaPoint = Level.area_points[room.area_index]
		var warp_room:FastTravelPoint = area.subpoints.filter(func(val:Point): return val is FastTravelPoint)[0]
		connect_rooms(current_room, warp_room.associated_room, true, true, true)

func set_protected_points(area:AreaPoint): #protect smallest series of points that connects area connectors with progression
	#get origin and destination
	var protected_points:Array[Point]
	var valid_area_connectors:Array = area.subpoints.filter(
		func(val:Point): return (val is ConnectionPoint) && val.area_relation_is_progress.has(true)
		)
	if len(valid_area_connectors) < 1: 
		return
	elif len(valid_area_connectors) == 1:
		set_area_origin_step(area, valid_area_connectors[0])
		return
	var origin:ConnectionPoint = valid_area_connectors[0]
	var destination:ConnectionPoint = valid_area_connectors[len(valid_area_connectors)-1]
	#variables for shortest path problem with unweighted graph
	var visited = {}
	var parent = {}
	var queue:Array[Point] = []
	var distance = {}
	#initialize dictionary
	for point:Point in area.subpoints:
		visited[point] = false
		distance[point] = -1
		parent[point] = null
	visited[origin] = true
	distance[origin] = 0
	queue.append(origin)
	#bfs algorithm on subpoints graph
	while queue.size() > 0:
		var current = queue.pop_front()
		#shortest path found, protect points and return
		if current == destination:
			var step:Point = destination
			while step != null:
				step.is_protected = true
				step = parent[step]
			set_area_origin_step(area, origin)
			return
		#bfs iteration
		for neighbor in current.relations:
			if not visited[neighbor]:
				visited[neighbor] = true
				distance[neighbor] = distance[current] + 1
				parent[neighbor] = current
				queue.append(neighbor)

func set_area_origin_step(area:AreaPoint, origin:Point):
	for route_step:RouteStep in Level.route_steps:
		if area in route_step.areas:
			origin.associated_step = route_step
			return
	print('ERROR area ', area.area_index, ' not present in any steps!')

func check_protect_point(original:Point, new_point:Point, area:AreaPoint, area_step_points:Array[Point] = []):
	#check if point can be replaced
	if original.is_protected:
		var original_required_step_index:int = min_neighbor_step_index(original)
		var new_step_index:int = new_point.associated_step.index
		#if cant replace protected point, new point is connected to it instead of replacing
		if new_step_index > original_required_step_index:
			#add new point to area
			area.subpoints.push_back(new_point)
			original.relations.push_back(new_point)
			new_point.relations.push_back(original)
			area.add_subarea_nodes()
			#set step and remove from elegible pool
			original.is_generic = false #even though it's still generic, a new point is created so this keeps the total available balanced
			original.associated_step = Level.route_steps[original_required_step_index]
			area_step_points.erase(original)
			#move new point in a random direction so it doesen't overlap with original
			var intra_area_distance = area_size / float(len(area.subpoints))
			new_point.update_position(new_point.pos + Vector2(Utils.rng.randf_range(-1, 1), Utils.rng.randf_range(-1, 1)).normalized() * intra_area_distance)
			return
	#replace original point for new point
	new_point.absorb_relations(original)
	new_point.is_protected = original.is_protected #just for visualization purposes
	var replace_index:int = area.subpoints.find(original)
	area.subpoints[replace_index] = new_point
	area_step_points.erase(original)
	#manage memory and scene tree
	area.remove_child(original)
	original.queue_free()
	area.add_subarea_nodes()

func min_neighbor_step_index(point:Point, seen_points:Array[Point] = []) -> int: #propagates over other indexless points
	seen_points.push_back(point)
	#base case
	if point.associated_step != null:
		return point.associated_step.index
	#recursive case
	else:
		var index 
		var min_index = INF
		var dead_end:bool = true
		for relation:Point in point.relations:
			if !seen_points.has(relation):
				dead_end = false
				index = min_neighbor_step_index(relation, seen_points)
				if index < min_index:
					min_index = index
		if dead_end: return 9999 #note: int(INF) cast results in negative number, fucks up calculation, return this instead
		else: return min_index

func gate_adjacent_rooms(origin:Room):
	var route_step_index:int = origin.step_index
	var debug = Level.rooms
	if route_step_index == 0: return #first connections, no previous keys, no gates necessary
	var previous_step_keyset:Array[Reward] = Level.route_steps[route_step_index-1].keyset
	
	for current_mu:MU in origin.room_MUs:
		for direction:Utils.direction in range(4):
			var border:Utils.border_type = current_mu.borders[direction]
			if border == Utils.border_type.LOCKED_DOOR:
				var direction_vec:Vector2i = Utils.direction_to_vec2i(direction)
				var adjacent_connected_mu:MU = Level.map.get_mu_at(current_mu.grid_pos + direction_vec)
				if current_mu.border_data[direction].is_protected: continue #do not overwrite protected gaets
				if adjacent_connected_mu.parent_room.step_index != origin.step_index:
					var connection_gate:LockedDoor = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, previous_step_keyset)
					current_mu.borders[direction] = Utils.border_type.LOCKED_DOOR
					current_mu.border_data[direction] = connection_gate
					var neg_direction:Utils.direction = Utils.opposite_direction(direction)
					adjacent_connected_mu.borders[neg_direction] = Utils.border_type.LOCKED_DOOR
					adjacent_connected_mu.border_data[neg_direction] = connection_gate

func connect_adjacent_rooms(r1:Room, r2:Room, gate:LockedDoor = null, protect_gate:bool=false): 
	var r1_to_r2:Vector2i = r2.grid_pos - r1.grid_pos
	var r1_candidates:Array[Vector2i]
	var x_candidates:Array #either x or y is always length 1 (different for each call)
	var y_candidates:Array
	var overlap:int
	var connection_gate:LockedDoor
	var direction_vec:Vector2i
	#create default gate if not given
	if gate == null:
		connection_gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY)
	else:
		connection_gate = gate
	connection_gate.is_protected = protect_gate
	#compute candidate MUs in r1 adjacent to r2
	if r1_to_r2.x < 0:
		overlap = r2.grid_pos.x + r2.room_size.x - r1.grid_pos.x
		if overlap == 0: overlap = 1
		else: direction_vec = Vector2i(0, 1 * sign(r1_to_r2.y))
		x_candidates = range(overlap)
	elif r1_to_r2.x == 0:
		overlap = min(r1.room_size.x, r2.room_size.x)
		direction_vec = Vector2i(0, 1 * sign(r1_to_r2.y))
		x_candidates = range(overlap)
	else:
		overlap = r1.grid_pos.x + r1.room_size.x - r2.grid_pos.x
		if overlap == 0: overlap = 1
		else: direction_vec = Vector2i(0, 1 * sign(r1_to_r2.y))
		x_candidates = range(r1.room_size.x - overlap, r1.room_size.x)
	if r1_to_r2.y < 0:
		overlap = r2.grid_pos.y + r2.room_size.y - r1.grid_pos.y
		if overlap == 0: overlap = 1
		else: direction_vec = Vector2i(1 * sign(r1_to_r2.x), 0)
		y_candidates = range(overlap)
	elif r1_to_r2.y == 0:
		overlap = min(r1.room_size.y, r2.room_size.y)
		direction_vec = Vector2i(1 * sign(r1_to_r2.x), 0)
		y_candidates = range(overlap)
	else:
		overlap = r1.grid_pos.y + r1.room_size.y - r2.grid_pos.y
		if overlap == 0: overlap = 1
		else: direction_vec = Vector2i(1 * sign(r1_to_r2.x), 0)
		y_candidates = range(r1.room_size.y - overlap, r1.room_size.y)
	r1_candidates.resize(len(x_candidates) * len(y_candidates))
	var index:int = 0
	for x_candidate in x_candidates:
		for y_candidate in y_candidates:
			r1_candidates[index] = Vector2i(x_candidate, y_candidate)
			index += 1
	#roll MU and get r2 correspondant
	var rand_index:int = Utils.rng.randf_range(0, len(r1_candidates)-1)
	var r1_mu:MU = Level.map.get_mu_at(r1.grid_pos + r1_candidates[rand_index])
	var r2_mu:MU = Level.map.get_mu_at(r1_mu.grid_pos + direction_vec)
	#connect rooms by selected MUs
	var direction = Utils.vec2i_to_direction(direction_vec)
	r1_mu.borders[direction] = Utils.border_type.LOCKED_DOOR
	r1_mu.border_data[direction] = connection_gate
	var neg_direction:Utils.direction = Utils.opposite_direction(direction)
	r2_mu.borders[neg_direction] = Utils.border_type.LOCKED_DOOR
	r2_mu.border_data[neg_direction] = connection_gate

const ROOM_MEMORY:int = 3
func connect_rooms(origin:Room, destination:Room, is_progress:bool = true, can_reuse_gates:bool = false, force_first_gate:bool = false):
	var current_room:Room = origin
	var room_history:Array[Room] = []
	room_history.resize(ROOM_MEMORY)
	var current_MU:MU
	var direction:Utils.direction
	var current_pos:Vector2i
	var direction_vec:Vector2i
	var next_mu_pos:Vector2i
	var new_room_step_index:int = max(origin.step_index, destination.step_index)
	var higher_step_previous_keyset:Array[Reward] = Level.route_steps[new_room_step_index - 1].keyset
	var reuse_one_gate:bool = false
	var on_existing_path:bool = false
	
	#step 0, get non-randomized direction
	direction_vec = Utils.absolute_direction(origin.grid_pos, destination.grid_pos) #BUG
	direction = Utils.vec2i_to_direction(direction_vec)
	var count:int = 0
	var skip_direction_computation:bool = true
	while true:
		#debug instructions
		count +=1
		if count == 1000:
			print('LIMIT REACHED FROM ', origin.grid_pos, ' TO ', destination.grid_pos, ' IN ROOM ', current_room.grid_pos)
			return
		#weighted random walk: decide direction
		if !skip_direction_computation:
			direction = weighted_random_walk_dir(current_pos, destination.grid_pos)
			direction_vec = Utils.direction_to_vec2i(direction)
		skip_direction_computation = false
		current_MU = current_room.get_mu_towards(direction)
		current_pos = current_MU.grid_pos
		next_mu_pos = current_pos + direction_vec
		#force next direction if trying to move out of bounds
		if next_mu_pos.x > Level.map_size_x/2 - 1 || next_mu_pos.x < -Level.map_size_x/2 || next_mu_pos.y > Level.map_size_y/2 - 1 || next_mu_pos.y < -Level.map_size_y/2: 
			direction = (direction+1)%4
			direction_vec = Utils.direction_to_vec2i(direction)
			skip_direction_computation = true
			continue
		var target_mu:MU = Level.map.get_mu_at(next_mu_pos)
		if count==0 && origin.step_index != destination.step_index: on_existing_path = (true if target_mu == null else false)
		#adjacent room exists
		if target_mu != null:
			#must force gate but would overwrite existing one, reroll
			if force_first_gate && current_MU.borders[direction] == Utils.border_type.LOCKED_DOOR:
				continue
			#adjacent room is destination
			elif target_mu.parent_room == destination:
				var gate:LockedDoor = null
				#gate entrance to new room
				if (origin.step_index != destination.step_index) && (current_MU.borders[direction] != Utils.border_type.LOCKED_DOOR || current_MU.border_data[direction].keyset == higher_step_previous_keyset):
					gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
				connect_adjacent_rooms(current_room, target_mu.parent_room, gate)
				return
			#adjacent room in memory, reroll
			elif target_mu.parent_room in room_history: #avoids creating superfluous rooms
				reuse_one_gate = !_can_proceed_normally(current_room, room_history) #reuse gate if no available paths left
				continue
			#adjacent room connection exists, avoid overwriting TODO: try other mu instead of rerolling
			elif !(can_reuse_gates || reuse_one_gate) && current_MU.borders[direction] == Utils.border_type.LOCKED_DOOR:
				reuse_one_gate = !_can_proceed_normally(current_room, room_history) #reuse gate if no available paths left
				continue
			#reuse gate if allowed and applicable
			elif (can_reuse_gates || reuse_one_gate) && current_MU.borders[direction] == Utils.border_type.LOCKED_DOOR && current_MU.border_data[direction].directionality == Utils.gate_directionality.TWO_WAY && len(current_MU.border_data[direction].keyset) == 0:
				_room_connection_memory(room_history, current_room)
				current_room = target_mu.parent_room
				on_existing_path = true
				reuse_one_gate = false
			#adjacent room is existing of higher step index, gate existing connections before entering
			elif (origin.step_index < target_mu.parent_room.step_index):
				gate_adjacent_rooms(target_mu.parent_room)
				connect_adjacent_rooms(current_room, target_mu.parent_room, null, true) #protect gates to maintain routes in case a room is entered to by lower steps in multiple instances (avoid hardlocks)
				_room_connection_memory(room_history, current_room)
				current_room = target_mu.parent_room
			#adjacent room is existing of lower step index
			elif (!on_existing_path || force_first_gate) && (origin.step_index > target_mu.parent_room.step_index):
				var connection_gate:LockedDoor
				if is_progress:
					connection_gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
				else:
					connection_gate = LockedDoor.createNew(Utils.gate_state.OPEN, Utils.gate_directionality.ONE_WAY, Utils.opposite_direction(direction))
				connect_adjacent_rooms(current_room, target_mu.parent_room, connection_gate)
				_room_connection_memory(room_history, current_room)
				current_room = target_mu.parent_room
				on_existing_path = true
				force_first_gate = false
			#adjacent room is existing, same index
			else:
				var gate:LockedDoor = null
				if force_first_gate:
					LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
					force_first_gate = false
				connect_adjacent_rooms(current_room, target_mu.parent_room, gate)
				_room_connection_memory(room_history, current_room)
				current_room = target_mu.parent_room
		#create new room
		else:
			var room_position:Vector2i 
			var room_dimensions:Vector2i 
			#avoid room superposition
			while !Room.canCreate(room_position, room_dimensions):
				#reroll direction to avoid crashing on map limit
				direction = weighted_random_walk_dir(current_pos, destination.grid_pos)
				direction_vec = Utils.direction_to_vec2i(direction)
				room_dimensions = Vector2i(Utils.rng.randi_range(1, 3), Utils.rng.randi_range(1, 3)) #TODO: weights based on position difference current->objective
				if direction_vec.x < 0 || direction_vec.y < 0:
					room_position = current_pos + direction_vec * room_dimensions
				else:
					room_position = current_pos + direction_vec
			var new_room:Room = Room.createNew(room_position, origin.area_index, new_room_step_index, room_dimensions) 
			new_room.createRoomMUs()
			#create gate to connect if necessary
			var connection_gate:LockedDoor = null
			if (on_existing_path || force_first_gate):
				if is_progress:
					connection_gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
				else:
					connection_gate = LockedDoor.createNew(Utils.gate_state.OPEN, Utils.gate_directionality.ONE_WAY, Utils.opposite_direction(direction))
				on_existing_path = false
				force_first_gate = false
			connect_adjacent_rooms(current_room, new_room, connection_gate)
			_room_connection_memory(room_history, current_room)
			current_room = new_room
			current_pos = current_room.grid_pos #room position used only for direction computation

func _can_proceed_normally(room:Room, room_memory:Array[Room]) -> bool:
	var can_continue:bool = false
	var adjacent_mu:MU
	for room_mu:MU in room.room_MUs:
		for direction:Utils.direction in range(4):
			if room_mu.borders[direction] == Utils.border_type.LOCKED_DOOR || Utils.border_type.SAME_ROOM:
				continue
			adjacent_mu = Level.map.get_mu_at(room_mu.grid_pos + Utils.direction_to_vec2i(direction))
			if adjacent_mu == null: 
				return true
			elif adjacent_mu.parent_room.step_index > room.step_index:
				continue
			elif adjacent_mu.parent_room in room_memory:
				continue
			#adjacent room in equal or lower step index
			else:
				return true
	return can_continue

func _room_connection_memory(room_memory:Array[Room], previous_room:Room):
	for i:int in range(ROOM_MEMORY-1):
		room_memory[i] = room_memory[i+1]
	room_memory[ROOM_MEMORY-1] = previous_room

func weighted_random_walk_dir(current_pos:Vector2i, destination:Vector2i) -> Utils.direction:
	var direction:Utils.direction
	var weights:Array[float] = compute_direction_weighs(current_pos, destination)
	var roll = Utils.rng.randf_range(0,1)
	var sum:float = 0
	for i:int in range(4):
		sum += weights[i]
		if sum > roll:
			direction = i
			break
	#var test = (Utils.absolute_direction(current_pos, destination))
	return direction

func compute_direction_weighs(position:Vector2i, objective:Vector2i) -> Array[float]:
	var direction_to_objective:Vector2 = Vector2(objective - position)
	var result:Array[float]
	result.resize(4)
	var sum:float = 0.0
	#get weight for each direction
	for direction:Utils.direction in range(4):
		var direction_vector:Vector2 = Utils.direction_to_vec2i(direction)
		var weight:float = clampf(direction_vector.dot(direction_to_objective), 0.01, 1.0) #TODO: tweak min
		result[direction] = weight
		sum += weight
	for i:int in range(4):
		result[i] = result[i] / sum
	return result

func get_random_MU(room:Room) -> MU: #TODO: move this to Room class, move Utils.rng to Utils
	return room.room_MUs[Utils.rng.randi_range(0, len(room.room_MUs)-1)]

func get_free_MU(room:Room) -> MU: #TODO make random
	for room_mu:MU in room.room_MUs:
		if len(room_mu.rewards) == 0 && !room_mu.is_fast_travel && !room_mu.is_save && !room_mu.is_shop && !room_mu.is_spawn:
			return room_mu
	return null

func get_area_step_points(area:AreaPoint, number_of_points:int, spawn_placed:bool = true) -> Array[Point]:
	#get starting point
	var starting_point:Point
	#first step of initial area includes connector to next area (to prevent softlocks)
	if area.area_index == 0 && !spawn_placed:
		var point_candidates:Array = area.subpoints.filter(func(val:Point): return val is ConnectionPoint)
		#single area world, choose point at random TODO:most isolated instead of random
		if len(point_candidates) == 0:
			var subpoint_index = Utils.rng.randi_range(0, len(area.subpoints)-1)
			starting_point = area.subpoints[subpoint_index]
		#find connector to second area
		else:
			var second_area:AreaPoint = Level.area_points[1]
			var second_area_connectors:Array = second_area.subpoints.filter(func(val:Point): return val is ConnectionPoint)
			var second_area_inter_connectors = second_area_connectors.reduce(
				func(acc:Array, val:ConnectionPoint): 
				return acc + val.area_relations 
				, [])
			starting_point = get_intersection(point_candidates, second_area_inter_connectors)[0]
	#step in first area, expand from spawn
	elif area.area_index == 0:
		starting_point = area.subpoints.filter(func(val): return val is SpawnPoint)[0]
	#first step includes connector to previous area
	else:
		var point_candidates:Array = area.subpoints.filter(func(val:Point): return val is ConnectionPoint)
		#find previous area
		var previous_area:AreaPoint
		for i:int in range(len(area.relations)):
			var relation:AreaPoint = area.relations[i]
			var is_progress:bool = area.relation_is_progress[i]
			if relation.area_index < area.area_index && is_progress: #always one in current implementation
				previous_area = relation
				break
		#find current area's connector to previous area
		var previous_area_connectors:Array = previous_area.subpoints.filter(func(val:Point): return val is ConnectionPoint)
		var previous_area_inter_connectors = previous_area_connectors.reduce(
			func(acc:Array, val:ConnectionPoint): 
			return acc + val.area_relations 
			, [])
		starting_point = get_intersection(point_candidates, previous_area_inter_connectors)[0]
		
	#expand from starting point, DFS preorder graph
	var area_step_points:Array[Point] = []
	dfs_preorder_point_search(area_step_points, starting_point, number_of_points)
	return area_step_points

func dfs_preorder_point_search(accumulator:Array[Point], current_point:Point, max_num:int, seen_points:Array[Point] = []):
	seen_points.push_back(current_point)
	if len(accumulator) >= max_num: return
	elif current_point.is_generic:
		accumulator.push_back(current_point)
	if len(accumulator) >= max_num: return
	for relation:Point in current_point.relations:
		if relation in seen_points: continue
		dfs_preorder_point_search(accumulator, relation, max_num, seen_points)
		if len(accumulator) >= max_num: return ##either this or the first one is redundant

func get_intersection(arr1:Array, arr2:Array) -> Array:
	var intersection:Array = []
	for element in arr1:
		if element in arr2: intersection.push_back(element)
	return intersection

func steps_to_crossroads(point:Point, seen_points:Array[Point] = []) -> int:
	seen_points.push_back(point)
	#base case
	if len(point.relations) > 2:
		return 1
	#recursive case
	else:
		var steps:int
		var min_steps = INF
		var dead_end:bool=true
		for relation:Point in point.relations:
			if !seen_points.has(relation):
				steps = steps_to_crossroads(relation, seen_points)
				dead_end = false
				if steps < min_steps:
					min_steps = steps
		if dead_end: steps = 0
		else: steps = min_steps + 1
		return steps

func spawn_points(points:Array, pixel_dimensions:Vector2, is_area:bool = false): #Input: Array[Point] (or subclasses)
	for i in range(len(points)):
		#TODO better random procedure
		var random_pos = Vector2(Utils.rng.randf_range(-pixel_dimensions.x/2.0,pixel_dimensions.x/2.0), Utils.rng.randf_range(-pixel_dimensions.y/2.0, pixel_dimensions.y/2.0))
		var current_point = AreaPoint.createNew(random_pos) if is_area else Point.createNew(random_pos)
		points[i] = current_point

func ensure_min_dist_around(center_point:Point, points:Array, min_distance:float):
	var map_boundary_x:float = map_size_x*16/2.0 - 4.0 #note: the range in cells is actually (-n/2 to n/2-1) due to the 0 element, so some leeway is necessary
	var map_boundary_y:float = map_size_y*16/2.0 - 4.0
	for second_point:Point in points:
		if center_point == second_point: continue
		var distance:float = center_point.global_position.distance_to(second_point.global_position)
		#move points in conflict to current
		if (distance <= min_distance):
			var current_to_second:Vector2 = center_point.global_position.direction_to(second_point.global_position)
			second_point.update_position(second_point.pos + current_to_second * (min_distance - distance + 0.1))
			#ensure new position is inside map boundaries
			if abs(second_point.global_position.x) > map_boundary_x:
				var point_to_reflection:Vector2 = Vector2(1, 0) * (2 * (sign(second_point.global_position.x) * map_boundary_x - second_point.global_position.x))
				second_point.update_position(second_point.pos + point_to_reflection)
			elif abs(second_point.global_position.y) > map_boundary_y:
				var point_to_reflection:Vector2 = Vector2(0, 1) * (2 * (sign(second_point.global_position.y) * map_boundary_y - second_point.global_position.y))
				second_point.update_position(second_point.pos + point_to_reflection)

func expand_points(points:Array, center:Vector2, min_distance:float, expansion_factor:float = 0):
	#expand areas from center
	for current_point:Point in points:
		var center_to_area:Vector2 = current_point.global_position - center
		current_point.update_position(current_point.pos + center_to_area * expansion_factor) 
	#expand areas from each other
	#TODO: tweak parameters
	var map_boundary_x:float = map_size_x*16/2.0 - 4.0 #note: the range in cells is actually (-n/2 to n/2-1) due to the 0 element, so some leeway is necessary
	var map_boundary_y:float = map_size_y*16/2.0 - 4.0
	var clear = false
	var count:int = 0
	while !clear && min_distance > 0.0:
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

func connect_points(points:Array):
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


func clean_islands(points:Array):
	var remaining_points:Array = points.duplicate() #Array[Points]
	var point_islands:Array[Array] #Array[Array[Point]]
	
	#get all point islands
	for i:int in range(len(points)):
		var current_point:Point = points[i]
		if !(remaining_points.has(current_point)): continue
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
		draw_circle(current_area.pos, area_size*0.5, Color.BLACK, false)
		var area_rect:Rect2 = Rect2(current_area.position - Vector2(area_size/2.0, area_size/2.0), Vector2(area_size, area_size))
		draw_rect(area_rect, Color.BLACK, false)
		var intra_area_distance = area_size / float(len(current_area.subpoints))
		
		if draw_angles:
			for related_area:AreaPoint in current_area.relations:
				var angle = current_area.global_position.angle_to_point(related_area.global_position)
				var direction = Vector2(1,0)
				var angle_1 = direction.rotated(angle + MIN_ANGULAR_DISTANCE)
				var angle_2 = direction.rotated(angle - MIN_ANGULAR_DISTANCE)
				draw_line(current_area.position, current_area.position + angle_1 * 100, Color(0,0,0,0.3), 2, false)
				draw_line(current_area.position, current_area.position + angle_2 * 100, Color(0,0,0,0.3), 2, false)
		
		for subpoint:Point in current_area.subpoints:
			draw_circle(subpoint.global_position, intra_area_distance*0.5, Color.BLACK, false)
			
			var debug_index = current_area.subpoints.find(subpoint)
			draw_string(font , subpoint.global_position + Vector2(0,20), str(debug_index), 0, -1, 16, Color.BLACK)
			
			if subpoint.associated_step != null:
				draw_string(font , subpoint.global_position + Vector2(0,-40), str(subpoint.associated_step.index), 0, -1, 16, Color.DEEP_PINK)
			
			if subpoint is FastTravelPoint and current_area.has_hub:
				draw_circle(subpoint.global_position, intra_area_distance, Color.BLACK, false)
			
			if draw_angles:
				for related_point:Point in subpoint.relations:
					var angle = subpoint.global_position.angle_to_point(related_point.global_position)
					var direction = Vector2(1,0)
					var angle_1 = direction.rotated(angle + MIN_ANGULAR_DISTANCE)
					var angle_2 = direction.rotated(angle - MIN_ANGULAR_DISTANCE)
					draw_line(subpoint.global_position, subpoint.global_position + angle_1 * 50, Color(0,0,0,0.8), 1, false)
					draw_line(subpoint.global_position, subpoint.global_position + angle_2 * 50, Color(0,0,0,0.8), 1, false)
