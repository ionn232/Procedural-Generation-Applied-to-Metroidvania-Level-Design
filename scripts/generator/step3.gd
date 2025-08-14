extends Node

@onready var common: Node2D = $"../Common"

func execute(): ##establish area connections
	common.connect_points(Level.area_points)
