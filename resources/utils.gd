class_name Utils
extends Resource

static var rooms:Array[Array] = []
static var map_size_x:int
static var map_size_y:int

enum border_type {
	EMPTY = 0,
	WALL = 1,
	DEATH_ZONE = 2,
	LOCKED_DOOR = 3 
}

enum border {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3,
}

static func border_to_vec2i(input:border) -> Vector2i:
	match input:
		border.UP:
			return Vector2i(0,-1)
		border.DOWN:
			return Vector2i(0,1)
		border.LEFT:
			return Vector2i(-1,0)
		border.RIGHT:
			return Vector2i(1,0)
	print('❌ ERROR converting direction to vec2i: input value -> ', input)
	return Vector2i(-5, -5)

static func opposite_direction(direction:border) -> border:
	match direction:
		border.UP:
			return border.DOWN
		border.DOWN:
			return border.UP
		border.LEFT:
			return border.RIGHT
		_:
			return border.LEFT


static func initialize_room_data(size_x:int, size_y:int):
	map_size_x = size_x
	map_size_y = size_y
	rooms.resize(map_size_x)
	for i in rooms.size():
		var room_column:Array[Room] = []
		room_column.resize(map_size_y)
		room_column.fill(null)
		rooms[i] = room_column

static func is_pos_inside_map(pos:Vector2i) -> bool:
	if (pos.x >= map_size_x):
		return false
	elif (pos.y >= map_size_y):
		return false
	elif (pos.x < 0):
		return false
	elif (pos.y < 0):
		return false
	return true
