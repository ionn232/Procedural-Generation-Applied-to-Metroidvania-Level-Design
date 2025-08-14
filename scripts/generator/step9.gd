extends Node

@onready var common: Node2D = $"../Common"

func execute(): ##expand intra-area points
	for current_area:AreaPoint in Level.area_points:
		common.expand_points(current_area.subpoints, current_area.pos, current_area.intra_area_distance, Utils.ROOM_SIZE)
