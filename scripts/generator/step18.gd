extends Node

@onready var common: Node2D = $"../Common"

func execute(): ##Extrude keyset rooms 
	#ascending order to avoid timeouts
	for step:RouteStep in Level.route_steps:
		for current_room:Room in Level.keyset_rooms:
			if current_room.step_index == step.index && !(current_room.is_trap):
				common.extrude_reward_room(current_room)
