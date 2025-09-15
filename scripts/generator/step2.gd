extends Node

@onready var common: Common = $"../Common"
@onready var generator: MapGenerator = $".."

func execute(): ##expand points from centroid and ensure minimum distance
	#calculate centroid
	var centroid : Vector2 = Vector2(0,0)
	for area_point:AreaPoint in Level.area_points:
		centroid += area_point.pos
	centroid.x /= len(Level.area_points)
	centroid.y /= len(Level.area_points)
	#expand areas from centroid
	common.expand_points(Level.area_points, centroid, generator.area_size_xy, Utils.ROOM_SIZE)
