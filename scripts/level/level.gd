class_name Level
extends Resource

#The complete map contains all MUs
static var map: Map

#Room registers
static var rooms: Array[Room]
static var initial_room:Room
static var keyset_rooms:Array[Room]
static var trap_rooms:Array[Room]

#for each step i, for each number of minor rewards j, stores a room that is part of step i and currently has j minor rewards
static var minor_reward_room_counts:Array[Array]  #type: Array[Array[Array[Room]]]

#map size
static var map_size_x:int
static var map_size_y:int

static var area_size_multiplier:float

#area points
static var num_areas:int
static var area_points:Array[AreaPoint]
static var initial_area:AreaPoint

#route steps
static var num_route_steps:int
static var route_steps:Array[RouteStep]
