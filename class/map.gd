class_name Map
extends Resource

var rooms:Array[Array] = []

func initialize_map():
	rooms.resize(Level.map_size_x)
	for i in rooms.size():
		var room_column:Array[Room] = []
		room_column.resize(Level.map_size_y)
		room_column.fill(null)
		rooms[i] = room_column
