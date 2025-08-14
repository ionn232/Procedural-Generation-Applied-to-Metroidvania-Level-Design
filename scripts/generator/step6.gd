extends Node

func execute(): ##establish area-rs relations
	var num_areas_left:int = Level.num_areas
	var num_rs_left:int = Level.num_route_steps
	var route_steps:Array[RouteStep] = Level.route_steps
	var area_index:int = 0
	for i:int in range(Level.num_route_steps):
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
