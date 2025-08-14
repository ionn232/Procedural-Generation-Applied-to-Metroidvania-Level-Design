extends Node

@onready var common: Node2D = $"../Common"

func execute(): ##Reassign room areas
	for i:int in range(Level.num_route_steps):
		for current_room:Room in Level.rooms:
			if current_room.step_index != i: continue
			current_room.mimic_adjacent_rooms_area()
