class_name Map
extends Resource

static var rooms:Array[Array] = []
static var map_size_x:int
static var map_size_y:int

static var initial_room:Room

static func initialize_map(size_x:int, size_y:int):
	map_size_x = size_x
	map_size_y = size_y
	rooms.resize(map_size_x)
	for i in rooms.size():
		var room_column:Array[Room] = []
		room_column.resize(map_size_y)
		room_column.fill(null)
		rooms[i] = room_column
