extends Node

func execute(): ##Place rooms for main upgrades, keyset units, side upgrades, area connectors and spawn room
	for i:int in range(len(Level.area_points)):
		var current_area:AreaPoint = Level.area_points[i]
		for j:int in range(len(current_area.subpoints)):
			var current_point:Point = current_area.subpoints[j]
			current_point.random_reposition()
			var room_position:Vector2i = Utils.world_pos_to_room(current_point.global_position)
			var room_dimensions:Vector2i = Vector2i(Utils.rng.randi_range(1, 3), Utils.rng.randi_range(1, 3))
			#reroll size to avoid room superposition
			while !Room.canCreate(Vector2i(room_position.x - room_dimensions.x/2, room_position.y - room_dimensions.y/2), room_dimensions, current_point):
				room_dimensions = Vector2i(Utils.rng.randi_range(1, 3), Utils.rng.randi_range(1, 3))
			var new_room:Room = Room.createNew(Vector2i(room_position.x - room_dimensions.x/2, room_position.y - room_dimensions.y/2), current_area.area_index, current_point.associated_step.index , room_dimensions, current_point)
			current_point.associated_room = new_room
			var random_room_mu:MU = new_room.get_random_MU()
			
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
