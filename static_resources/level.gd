class_name Level
extends Resource

#The complete map contains all rooms of all sections
static var complete_map: Map
#Each section has the same size map, but no 2 sections can occupy the same coordinates
static var sections: Array[Map]

#Size of all maps
static var map_size_x:int
static var map_size_y:int

static var initial_room:Room
