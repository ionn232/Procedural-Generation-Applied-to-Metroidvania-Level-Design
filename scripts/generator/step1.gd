extends Node

@onready var main_scene: Node2D = $"../.."
@onready var common: Node2D = $"../Common"

func execute(): ##1: place as many points as the number of areas
	var area_points : Array[AreaPoint] = []
	area_points.resize(Level.num_areas)
	common.spawn_points(area_points, Vector2(Level.map_size_x, Level.map_size_y), true)
	Level.area_points = area_points
	main_scene.layout_display.add_area_nodes()
