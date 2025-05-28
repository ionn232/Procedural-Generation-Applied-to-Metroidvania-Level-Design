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
static var map_size_x:int = 80
static var map_size_y:int = 80
static var area_size_xy:Vector2
static var area_size_multiplier:float = 2.5

#loot
static var num_side_upgrades:int = 5
static var num_equipment:int = 20
static var num_collectibles:int = 20
static var num_stat_ups:int = 20

static var backtracking_factor:float = 0.1

#area points
static var num_areas:int = 10
static var area_points:Array[AreaPoint]
static var initial_area:AreaPoint

#route steps
static var num_route_steps:int = 12
static var route_steps:Array[RouteStep]

#reset
static func reset():
	rooms.resize(0)
	keyset_rooms.resize(0)
	trap_rooms.resize(0)
	minor_reward_room_counts.resize(0)
	area_points.resize(0)
	route_steps.resize(0)
	map.MUs.resize(0)
	map.initialize_map()
	
