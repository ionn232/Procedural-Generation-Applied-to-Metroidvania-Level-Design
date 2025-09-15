extends Node

@onready var common: Common = $"../Common"

func execute(): ##assign points as spawn point, side upgrades, main upgrades and key item units
	#identify protected points for each area beyond initial
	for current_area:AreaPoint in Level.area_points:
		if current_area.area_index == 0: continue #spawn point placement procedure takes care of the problem
		common.set_protected_points(current_area)
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
			var area_step_keyset:Array = common.array_inner_join(step_keyset_flat, current_area.reward_pool)
			#Array[SideUpgrade]
			var area_step_SUs:Array = common.array_inner_join(current_step.reward_pool, current_area.reward_pool).filter(func(val): return val is SideUpgrade)
			var area_step_points:Array[Point] = common.get_area_step_points(current_area, len(area_step_keyset) + len(area_step_SUs) + (1 if !spawn_placed else 0), spawn_placed)
			
			#assign spawn point TODO:fuse with keyset points procedure (its the same)
			if !spawn_placed:
				var best_candidate:Point = null
				var max_steps_to_crossroads:int = -1
				for l:int in range(len(area_step_points)):
					var current_candidate:Point = area_step_points[l]
					if !(current_candidate.is_generic): continue
					var crossroad_step_distance:int = common.steps_to_crossroads(current_candidate)
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
						var crossroad_step_distance:int = common.steps_to_crossroads(current_candidate)
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
					common.check_protect_point(best_candidate, key_point, current_area, area_step_points)
			#assign any point for side upgrades (only points left for this area-step)
			for k:int in range(len(area_step_SUs)):
				var generic_point:Point = area_step_points[k]
				var SU_reward:Reward = area_step_SUs[k]
				var SU_point:SideUpgradePoint = SideUpgradePoint.createNew(generic_point.position, generic_point)
				SU_point.set_data(SU_reward, current_step)
				SU_point.associated_step = current_step
				common.check_protect_point(generic_point, SU_point, current_area)
	
	#necessary computations for next steps
	var current_area_index:int = -1
	for current_step:RouteStep in Level.route_steps:
		for current_area:AreaPoint in current_step.areas:
			if current_area.area_index > current_area_index:
				current_area_index = current_area.area_index
				for subpoint:Point in current_area.subpoints:
					#allocate memory for point relation tracking
					subpoint.relation_is_mapped.resize(len(subpoint.relations))
					subpoint.relation_is_mapped.fill(false)
					#assign step indexes for connector points and fast travel points
					if (subpoint is FastTravelPoint):
						var min_neighbor_step_index = common.min_neighbor_step_index(subpoint)
						subpoint.associated_step = Level.route_steps[min_neighbor_step_index]
					elif (subpoint is ConnectionPoint):
						subpoint.area_relation_is_mapped.resize(len(subpoint.area_relations))
						subpoint.area_relation_is_mapped.fill(false)
						var min_neighbor_step_index = common.min_neighbor_step_index(subpoint)
						subpoint.associated_step = Level.route_steps[min_neighbor_step_index]
