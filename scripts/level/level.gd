class_name Level
extends Resource

#The complete map contains all MUs
static var map: Map

#The complete list of rooms
static var rooms: Array[Room]
static var initial_room:Room
static var keyset_rooms:Array[Room]
static var trap_rooms:Array[Room]

#map size
static var map_size_x:int
static var map_size_y:int

#area points
static var num_areas:int
static var area_points:Array[AreaPoint]
static var initial_area:AreaPoint

#route steps
static var num_route_steps:int
static var route_steps:Array[RouteStep]
