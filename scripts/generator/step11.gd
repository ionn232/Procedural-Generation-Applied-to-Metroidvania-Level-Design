extends Node

@onready var common: Common = $"../Common"

func execute(): ##establish relations between area subpoints
	for current_area:AreaPoint in Level.area_points:
		common.connect_points(current_area.subpoints)
