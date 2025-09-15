extends Node

@onready var common: Common = $"../Common"

func execute(): ##Place hub zone rooms
	var hub_area:AreaPoint = Level.area_points.filter(func(val:AreaPoint): return val.has_hub)[0]
	var hub_position:Vector2 = Utils.world_pos_to_room(hub_area.subpoints.filter(func(val:Point): return val is FastTravelPoint)[0].global_position)
	var hub_room_1:Room = Level.map.MUs[hub_position.x][hub_position.y].parent_room
	#use existing room if there is space
	if hub_room_1.room_size.x * hub_room_1.room_size.y >= 3:
		var shop_mu:MU = hub_room_1.get_free_MU()
		shop_mu.is_shop = true
		var save_mu:MU = hub_room_1.get_free_MU()
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
			new_room_dimensions = [Vector2i(2,2), Vector2i(1,2), Vector2i(2,1)][Utils.rng.randi_range(0, 2)]
			if rand_direction_vec.x < 0 || rand_direction_vec.y < 0:
				new_room_pos = hub_room_1.grid_pos + rand_direction_vec * new_room_dimensions
			else:
				new_room_pos = hub_room_1.grid_pos + rand_direction_vec * hub_room_1.room_size
		var hub_room_2:Room = Room.createNew(new_room_pos, hub_area.area_index, hub_room_1.step_index , new_room_dimensions)
		var shop_mu:MU = hub_room_2.get_free_MU()
		shop_mu.is_shop = true
		var save_mu:MU = hub_room_2.get_free_MU()
		save_mu.is_save = true
		common.connect_adjacent_rooms(hub_room_1, hub_room_2)
