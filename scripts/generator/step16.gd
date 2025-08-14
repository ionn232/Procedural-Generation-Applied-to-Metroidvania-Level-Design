extends Node

@onready var common: Node2D = $"../Common"

func execute(): ##Map out connections
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
				common.gate_adjacent_rooms(current_point_room)
				#intra-area connections, only to those of current or lower steps for better map results
				for k:int in range(len(current_point.relations)):
					var relation:Point = current_point.relations[k]
					if relation.associated_step.index <= current_point.associated_step.index:
						var relation_room:Room = relation.associated_room
						if !current_point.relation_is_mapped[k]:
							common.connect_rooms(current_point.associated_room, relation_room)
							current_point.relation_is_mapped[k] = true
							relation.relation_is_mapped[relation.relations.find(current_point)] = true
				#inter-area connections, only those of current step or lower
				if current_point is ConnectionPoint:
					for k:int in range(len(current_point.area_relations)):
						var area_relation:Point = current_point.area_relations[k]
						if area_relation.associated_step.index <= current_point.associated_step.index:
							var relation_room:Room = area_relation.associated_room
							if !current_point.area_relation_is_mapped[k]:
								common.connect_rooms(current_point.associated_room, relation_room, current_point.area_relation_is_progress[k],false,true)
								current_point.area_relation_is_mapped[k] = true
								area_relation.area_relation_is_mapped[area_relation.area_relations.find(current_point)] = true
