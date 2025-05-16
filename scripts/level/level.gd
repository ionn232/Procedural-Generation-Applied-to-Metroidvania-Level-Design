class_name Level
extends Resource

#The complete map contains all MUs
static var map: Map

#The complete list of rooms
static var rooms: Array[Room]
#initial room #TODO:just make it first in rooms array
static var initial_room:Room

#map size
static var map_size_x:int
static var map_size_y:int

#area points
static var area_points:Array[AreaPoint]
static var initial_area:AreaPoint

#route steps
static var route_steps:Array[RouteStep]
