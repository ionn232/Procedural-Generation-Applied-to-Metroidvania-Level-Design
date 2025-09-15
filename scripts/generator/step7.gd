extends Node

@onready var common: Common = $"../Common"
@onready var generator: MapGenerator = $".."

func execute(): ##randomly place around areas a point for each relation, one for fast-travel room and one extra for spawn room
	for i:int in len(Level.area_points):
		var current_area:AreaPoint = Level.area_points[i]
		current_area.subpoints.resize(len(current_area.relations) + (2 if i == 0 else 1))
		#spawn points
		common.spawn_points(current_area.subpoints, Vector2(generator.area_size_rooms_xy.x, generator.area_size_rooms_xy.y))
		current_area.add_subarea_nodes()
