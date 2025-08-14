extends Node

@onready var main_scene: Node2D = $"../.."

func execute(): ##assign points as area connectors and establish relation
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
				
		#remove points as needed if relations 1:n exist
		var connector_count:int = current_area.subpoints.reduce(func(acc, val): return acc + int(val is ConnectionPoint), 0)
		var connector_pool:int = len(current_area.relations)
		var points_to_remove:int = connector_pool - connector_count
		for j:int in range(points_to_remove):
			var index:int = 0 #in case first point is connector
			while true:
				var removal_candidate = current_area.subpoints[index]
				if !(removal_candidate is ConnectionPoint):
					current_area.subpoints.pop_at(index)
					current_area.remove_child(removal_candidate)
					removal_candidate.queue_free()
					break
				index += 1
	main_scene.layout_display.dim_area_nodes()
