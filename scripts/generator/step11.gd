extends Node

@onready var common: Node2D = $"../Common"

func execute(): ##establish relations between area subpoints
	for current_area:AreaPoint in Level.area_points:
		common.connect_points(current_area.subpoints)
