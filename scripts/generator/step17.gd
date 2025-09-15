extends Node

@onready var common: Common = $"../Common"

func execute(): ##Add save points
	var save_distance:int
	var save_room:Room
	var target_mu:MU
	for starting_room:Room in Level.keyset_rooms:
		save_distance = Utils.rng.randi_range(1, 3)
		save_room = common.dfs_get_room_at_dist(starting_room, save_distance)
		if save_room != null: 
			target_mu = save_room.get_random_MU()
			target_mu.is_save = true
