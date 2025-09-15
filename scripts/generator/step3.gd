extends Node

@onready var common: Common = $"../Common"

func execute(): ##establish area connections
	common.connect_points(Level.area_points)
