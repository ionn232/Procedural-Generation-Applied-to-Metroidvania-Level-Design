class_name Common
extends Node

##
##  POINT PLACEMENT FUNCTIONS
##

func spawn_points(points:Array, pixel_dimensions:Vector2, is_area:bool = false): #points: Array[Point]
	for i in range(len(points)):
		var random_pos = Vector2(Utils.rng.randf_range(-pixel_dimensions.x/2.0,pixel_dimensions.x/2.0), Utils.rng.randf_range(-pixel_dimensions.y/2.0, pixel_dimensions.y/2.0))
		var current_point = AreaPoint.createNew(random_pos) if is_area else Point.createNew(random_pos)
		points[i] = current_point

func expand_points(points:Array, center:Vector2, min_distance:Vector2, expansion_factor:float = 0):
	#expand points from center
	for current_point:Point in points:
		var center_to_point:Vector2 = current_point.global_position - center
		current_point.update_position(current_point.pos + center_to_point * expansion_factor) 
	#expand points from each other
	#note: the range in cells is actually (-n/2 to n/2-1) due to the 0 element, so some leeway is necessary
	var map_boundary_x:float = Level.map_size_x*16/2.0 - 4.0 
	var map_boundary_y:float = Level.map_size_y*16/2.0 - 4.0
	var clear = false
	var count:int = 0
	while !clear && min_distance.x > 0.0 && min_distance.y > 0.0:
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
				var distance:Vector2 = second_point.global_position - current_point.global_position
				#move points in conflict to current
				if abs(distance.x) < min_distance.x && abs(distance.y) < min_distance.y:
					var mult_factors:Vector2 = Vector2( (min_distance.x / abs(distance.x)) , min_distance.y / abs(distance.y)) 
					second_point.update_position(current_point.pos + (distance + 0.1 * Vector2(sign(distance.x), sign(distance.y))) * Vector2(mult_factors[mult_factors.min_axis_index()], mult_factors[mult_factors.min_axis_index()])) #DO NOT REMOVE THE 0.1
					clear = false

func ensure_min_dist_around(center_point:Point, points:Array, min_distance:Vector2):
	#note: the range in cells is actually (-n/2 to n/2-1) due to the 0 element, so some leeway is necessary
	var map_boundary_x:float = Level.map_size_x*16/2.0 - 5.0 
	var map_boundary_y:float = Level.map_size_y*16/2.0 - 5.0
	for second_point:Point in points:
		if center_point == second_point: continue
		var distance:Vector2 = second_point.global_position - center_point.global_position
		#move points in conflict to current
		if abs(distance.x) < min_distance.x && abs(distance.y) < min_distance.y:
			var mult_factors:Vector2 = Vector2( (min_distance.x / abs(distance.x)) , min_distance.y / abs(distance.y)) 
			second_point.update_position(center_point.pos + (distance) * Vector2(mult_factors[mult_factors.min_axis_index()], mult_factors[mult_factors.min_axis_index()])) #DO NOT REMOVE THE 0.1
			#ensure new position is inside map boundaries
			if abs(second_point.global_position.x) > map_boundary_x:
				var point_to_reflection:Vector2 = Vector2(1, 0) * (2 * (sign(second_point.global_position.x) * map_boundary_x - second_point.global_position.x))
				second_point.update_position(second_point.pos + point_to_reflection)
			elif abs(second_point.global_position.y) > map_boundary_y:
				var point_to_reflection:Vector2 = Vector2(0, 1) * (2 * (sign(second_point.global_position.y) * map_boundary_y - second_point.global_position.y))
				second_point.update_position(second_point.pos + point_to_reflection)

##
## POINT CONNECTION FUNCTIONS
##

func connect_points(points:Array):
	for i:int in range(len(points)):
		var current_point:Point = points[i]
		compute_point_relations(points, i)
	clean_islands(points) #TODO: currently not doing anything, will be needed for higher values of angular distance if made customizable

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
		clear_incompatible_relations(points[j])
	clear_incompatible_relations(current_point)

func decide_relations(points:Array, current_point:Point, angles:Array, angle_candidates:Array):
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
			if angles_collide(second_point_angle, existing_relation_angle): 
				suitable = false
				var distance_existing:float = current_point.global_position.distance_squared_to(points[k].global_position)
				var distance_new:float = current_point.global_position.distance_squared_to(points[j].global_position)
				if distance_new < distance_existing:
					angle_candidates[k] = null
					angle_candidates[j] = angles[j]
		if suitable:
			angle_candidates[j] = second_point_angle

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
		point_islands.pop_front() #TODO better memory management

func get_island(island_points:Array[Point], current_point:Point):
	if island_points.has(current_point): return
	island_points.push_back(current_point)
	for i:int in range(len(current_point.relations)):
		var relation = current_point.relations[i]
		get_island(island_points, relation)

func clear_incompatible_relations(point:Point): #iterate over point relations. resolve relation conflicts
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
			if angles_collide(angle, previous_relation_angle): 
				var distance_previous:float = point.global_position.distance_squared_to(previous_relation.global_position)
				var distance_current:float = point.global_position.distance_squared_to(relation.global_position)
				if distance_current > distance_previous:
					relations_to_remove.push_back(relation)
				else:
					relations_to_remove.push_back(previous_relation)
	for deprecated_relation:Point in relations_to_remove:
		point.relations.erase(deprecated_relation)
		deprecated_relation.relations.erase(point)

func angles_collide(angle_1:float, angle_2:float) -> bool:
	if abs(angle_1 - angle_2) < Utils.MIN_ANGULAR_DISTANCE:
		return true
	elif abs(angle_1) > PI/2 && abs(angle_2) > PI/2:
		var nu_angle_1:float = sign(angle_1) * PI - angle_1
		var nu_angle_2:float = sign(angle_2) * PI - angle_2
		if abs(nu_angle_2 - nu_angle_1) < Utils.MIN_ANGULAR_DISTANCE:
			return true
	return false

##
## POINT SPECIALIZATION FUNCTIONS
##

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
			new_point.random_reposition(true)
			ensure_min_dist_around(new_point, area.subpoints, area.intra_area_distance)
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

##
## POINT SEARCH FUNCTIONS
##

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
			starting_point = array_inner_join(point_candidates, second_area_inter_connectors)[0]
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
		starting_point = array_inner_join(point_candidates, previous_area_inter_connectors)[0]
		
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

##
## ROOM CONNECTION FUNCTIONS
##

func connect_adjacent_mus(r1_mu:MU, r2_mu:MU, gate:LockedDoor = null, protect_gate:bool=false, r1_start:MU = null):
	var r1_to_r2:Vector2i = r2_mu.grid_pos - r1_mu.grid_pos
	var connection_gate:LockedDoor
	#create default gate if not given
	if gate == null:
		connection_gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY)
	else:
		connection_gate = gate
	connection_gate.is_protected = protect_gate
	if r1_mu.parent_room == r2_mu.parent_room:
		print('ERROR: call to connect_adjacent_mus of same room ', r1_mu.grid_pos)
	#connect rooms by selected MUs
	var direction = Utils.vec2i_to_direction(r1_to_r2)
	r1_mu.borders[direction] = Utils.border_type.LOCKED_DOOR
	r1_mu.border_data[direction] = connection_gate
	var neg_direction:Utils.direction = Utils.opposite_direction(direction)
	r2_mu.borders[neg_direction] = Utils.border_type.LOCKED_DOOR
	r2_mu.border_data[neg_direction] = connection_gate
	#use initial and final room to set point weights
	if r1_start != null && !r1_start.parent_room.is_trap: _set_room_minor_reward_weights(r1_start.parent_room, r1_start, r1_mu)
	#return start point for use in next computations if necessary
	return r2_mu

#returns r2's selected mu if succesful, null otherwise (rooms alredy connected)
func connect_adjacent_rooms(r1:Room, r2:Room, gate:LockedDoor = null, protect_gate:bool=false, r1_start:MU =null): 
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
	var r1_mu:MU
	var r2_mu:MU
	var rand_index:int = Utils.rng.randf_range(0, len(r1_candidates)-1)
	r1_mu = Level.map.get_mu_at(r1.grid_pos + r1_candidates[rand_index])
	r2_mu = Level.map.get_mu_at(r1_mu.grid_pos + direction_vec)
	var direction = Utils.vec2i_to_direction(direction_vec)
	var neg_direction:Utils.direction = Utils.opposite_direction(direction)
	#abort if selected MUs are alredy connected (avoid impossible maps to form)
	if r1_mu.borders[direction] == Utils.border_type.LOCKED_DOOR || r1_mu.borders[direction] == Utils.border_type.LOCKED_DOOR:
		return null
	#connect rooms by selected MUs
	r1_mu.borders[direction] = Utils.border_type.LOCKED_DOOR
	r1_mu.border_data[direction] = connection_gate
	r2_mu.borders[neg_direction] = Utils.border_type.LOCKED_DOOR
	r2_mu.border_data[neg_direction] = connection_gate
	#use initial and final room to set point weights
	if r1_start != null && !r1.is_trap: _set_room_minor_reward_weights(r1, r1_start, r1_mu)
	#return start point for use in next computations if necessary
	return r2_mu

const ROOM_MEMORY:int = 3
func connect_rooms(origin:Room, destination:Room, is_progress:bool = true, can_reuse_gates:bool = false, force_first_gate:bool = false):
	var current_room:Room = origin
	var room_history:Array[Room] = []
	room_history.resize(ROOM_MEMORY)
	var room_entry_MU:MU
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
		count +=1
		#safeguard, abort procedure if stuck in infinite loop.
		if count == 1000:
			print('LIMIT REACHED FROM ', origin.grid_pos, ' TO ', destination.grid_pos, ' IN ROOM ', current_room.grid_pos)
			return
		#target is adjacent, try to complete procedure
		if current_room.is_adjacent_to(destination):
			var gate:LockedDoor = null
			#gate entrance to new room
			if is_progress && (origin.step_index != destination.step_index):
				gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
			elif !is_progress && (origin.step_index != destination.step_index):
				gate = LockedDoor.createNew(Utils.gate_state.OPEN, Utils.gate_directionality.ONE_WAY, direction if origin.step_index > destination.step_index else Utils.opposite_direction(direction))
			var try_connection = connect_adjacent_rooms(current_room, destination, gate, false, room_entry_MU)
			if try_connection != null: return
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
		if count==0 && origin.step_index != destination.step_index: on_existing_path = (true if target_mu == null else false) #BUG count==0 always false, starts at 1
		#adjacent room exists
		if target_mu != null:
			#must force gate but would overwrite existing one, reroll
			if force_first_gate && current_MU.borders[direction] == Utils.border_type.LOCKED_DOOR:
				continue
			#adjacent room is destination
			elif target_mu.parent_room == destination:
				var gate:LockedDoor = null
				#gate entrance to new room
				if is_progress && (origin.step_index != destination.step_index) && (current_MU.borders[direction] != Utils.border_type.LOCKED_DOOR || current_MU.border_data[direction].keyset == higher_step_previous_keyset):
					gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
				elif !is_progress && (origin.step_index != destination.step_index) && (current_MU.borders[direction] != Utils.border_type.LOCKED_DOOR || current_MU.border_data[direction].keyset == higher_step_previous_keyset):
					gate = LockedDoor.createNew(Utils.gate_state.OPEN, Utils.gate_directionality.ONE_WAY, direction if origin.step_index > destination.step_index else Utils.opposite_direction(direction))
				connect_adjacent_mus(current_MU, target_mu, gate, false, room_entry_MU)
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
				#_set_room_minor_reward_weights(current_room, room_entry_MU, current_MU)
				current_room = target_mu.parent_room
				room_entry_MU = target_mu
				on_existing_path = true
				reuse_one_gate = false
			#adjacent room is existing of higher step index, gate existing connections before entering (avoids point rooms)
			elif (origin.step_index < target_mu.parent_room.step_index) && (target_mu.parent_room.associated_point == null || target_mu.parent_room.associated_point is ConnectionPoint):
				gate_adjacent_rooms(target_mu.parent_room)
				room_entry_MU = connect_adjacent_mus(current_MU, target_mu, null, true, room_entry_MU) #protect gates to maintain routes in case a room is entered to by lower steps in multiple instances (avoid hardlocks)
				_room_connection_memory(room_history, current_room)
				current_room = target_mu.parent_room
			#adjacent room is existing of lower step index
			elif (!on_existing_path || force_first_gate) && (origin.step_index > target_mu.parent_room.step_index):
				var connection_gate:LockedDoor
				if is_progress:
					connection_gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
				else:
					connection_gate = LockedDoor.createNew(Utils.gate_state.OPEN, Utils.gate_directionality.ONE_WAY, direction if origin.step_index > destination.step_index else Utils.opposite_direction(direction))
				room_entry_MU = connect_adjacent_mus(current_MU, target_mu, connection_gate, false, room_entry_MU)
				_room_connection_memory(room_history, current_room)
				#_set_room_minor_reward_weights(current_room, room_entry_MU, current_MU)
				current_room = target_mu.parent_room
				on_existing_path = true
				force_first_gate = false
			#adjacent room is existing, same index
			elif origin.step_index == target_mu.parent_room.step_index:
				var gate:LockedDoor = null
				if force_first_gate:
					LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
					force_first_gate = false
				room_entry_MU = connect_adjacent_mus(current_MU, target_mu, gate, false, room_entry_MU)
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
			#create gate to connect if necessary
			var connection_gate:LockedDoor = null
			if (on_existing_path || force_first_gate):
				if is_progress:
					connection_gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, higher_step_previous_keyset)
				else:
					connection_gate = LockedDoor.createNew(Utils.gate_state.OPEN, Utils.gate_directionality.ONE_WAY, direction if origin.step_index > destination.step_index else Utils.opposite_direction(direction))
				on_existing_path = false
				force_first_gate = false
			room_entry_MU = connect_adjacent_rooms(current_room, new_room, connection_gate, false, room_entry_MU)
			_room_connection_memory(room_history, current_room)
			current_room = new_room
			current_pos = current_room.grid_pos #room position used only for direction computation

func _set_room_minor_reward_weights(room:Room, path_start:MU, path_end:MU):
	var current_difference:Vector2i = (path_end.grid_pos - path_start.grid_pos)
	var current_mu:MU = path_start
	#assign neutral score on path from start to end
	path_start.minor_reward_score = 0
	path_end.minor_reward_score = 0
	var roll:float = Utils.rng.randf()
	var direction_vec:Vector2i
	while current_mu != path_end:
		current_mu.minor_reward_score = 0
		#roll axis
		if current_difference.x != 0 && current_difference.y != 0:
			#advance X
			if roll >= 0.5:
				direction_vec = Vector2i(sign(current_difference.x), 0)
			#advance Y
			else:
				direction_vec = Vector2i(0, sign(current_difference.y))
		#singe valid axis 
		else:
			direction_vec = Vector2i(sign(current_difference.x), sign(current_difference.y))
		current_mu = Level.map.get_mu_at(current_mu.grid_pos + direction_vec)
		current_difference -= direction_vec
	#assign valid score to all remaining MUs in room
	room.minor_rewards_viable = false
	for mu:MU in room.room_MUs:
		if mu.minor_reward_score == 0: continue #initialized previously, dont overwrite
		room.minor_rewards_viable = true
		mu.minor_reward_score = 1

func _can_proceed_normally(room:Room, room_memory:Array[Room]) -> bool:
	var can_continue:bool = false
	var adjacent_mu:MU
	for room_mu:MU in room.room_MUs:
		for direction:Utils.direction in range(4):
			if room_mu.borders[direction] == Utils.border_type.LOCKED_DOOR || room_mu.borders[direction] == Utils.border_type.SAME_ROOM:
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
	return direction

func compute_direction_weighs(position:Vector2i, objective:Vector2i) -> Array[float]:
	var direction_to_objective:Vector2 = Vector2(objective - position)
	var result:Array[float]
	result.resize(4)
	var sum:float = 0.0
	#get weight for each direction
	for direction:Utils.direction in range(4):
		var direction_vector:Vector2 = Utils.direction_to_vec2i(direction)
		var weight:float = clampf(direction_vector.dot(direction_to_objective), 0.01, 1.0) #tweak parameters if needed
		result[direction] = weight
		sum += weight
	for i:int in range(4):
		result[i] = result[i] / sum
	return result

func gate_adjacent_rooms(origin:Room):
	var route_step_index:int = origin.step_index
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

##
## ROOM FIND AND CREATION FUNCTIONS
##

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

func extrude_reward_room(room:Room):
	if room.grid_pos == Vector2i(19,8):
		pass
	
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
			#connect
			var gate:LockedDoor 
			if current_reward is MainUpgrade && i == number_of_extrusions-1:
				gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.ONE_WAY, selected_direction)
			else:
				gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY)
			connect_adjacent_rooms(prev_extruded_room, current_room, gate)
	#set previous room as boss room
	current_room.step_index = room.step_index+1
	current_room.is_main_route_location = true
	prev_extruded_room.is_trap = true
	#set reward in new room
	current_room.get_free_MU().add_reward(current_reward)
	#set boss category
	var mu:MU 
	if prev_extruded_room.room_size.x > 1 || prev_extruded_room.room_size.y > 1: 
		mu = prev_extruded_room.get_free_MU()
	else: 
		mu = prev_extruded_room.room_MUs[0]
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

##
## MISC FUNCTIONS
##

func array_inner_join(arr1:Array, arr2:Array) -> Array:
	var intersection:Array = []
	for element in arr1:
		if element in arr2: intersection.push_back(element)
	return intersection
