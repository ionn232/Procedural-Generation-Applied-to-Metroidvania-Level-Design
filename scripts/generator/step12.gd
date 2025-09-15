extends Node

@onready var common: Common = $"../Common"

func execute(): ##assign points as fast-travel rooms
		for j:int in range(len(Level.area_points)):
			#identify unassigned subpoint with most relations
			var current_area:AreaPoint = Level.area_points[j]
			var best_candidate:Point
			var max_num_relations:int = -1
			for k:int in range(len(current_area.subpoints)):
				var current_candidate:Point = current_area.subpoints[k]
				if !(current_candidate.is_generic): continue
				var num_relations:int = len(current_candidate.relations)
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
				common.ensure_min_dist_around(fast_travel_point, current_area.subpoints, current_area.intra_area_distance*1.5)
