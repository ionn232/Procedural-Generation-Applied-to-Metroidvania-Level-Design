extends Node

func execute(): ##establish hub-containing area
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
