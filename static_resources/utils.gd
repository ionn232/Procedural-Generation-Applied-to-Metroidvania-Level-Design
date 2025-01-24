class_name Utils
extends Resource

static var gui_selected_room:Vector2i = Vector2i(0,0)

enum border_type {
	EMPTY = 0,
	WALL = 1,
	DEATH_ZONE = 2,
	LOCKED_DOOR = 3 
}

enum direction {
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3,
}

enum reward_type {
	MAIN_UPGRADE,
	SIDE_UPGRADE,
	EQUIPMENT,
	STAT_UPGRADES,
	COLLECTIBLES
}

enum gate_state {
	LOCKED,
	TWO_WAY,
	ONE_WAY,
	OPEN
}

enum room_weights {
	ISOLATED, #Rooms at the end of a path will have an isolated score, higher for longer path
	MEMORABLE, #Rooms placed at points of interest will have a higher memorable score
	PROXIMITY #Rooms will have lower proximity weights if they're close to main upgrades
}

static func direction_to_vec2i(input:direction) -> Vector2i:
	match input:
		direction.UP:
			return Vector2i(0,-1)
		direction.DOWN:
			return Vector2i(0,1)
		direction.LEFT:
			return Vector2i(-1,0)
		direction.RIGHT:
			return Vector2i(1,0)
	print('❌ ERROR converting direction to vec2i: input value -> ', input)
	return Vector2i(-5, -5)

static func opposite_direction(dir:direction) -> direction:
	match dir:
		direction.UP:
			return direction.DOWN
		direction.DOWN:
			return direction.UP
		direction.LEFT:
			return direction.RIGHT
		_:
			return direction.LEFT

static func is_pos_inside_map(pos:Vector2i) -> bool:
	if (pos.x >= Level.map_size_x):
		return false
	elif (pos.y >= Level.map_size_y):
		return false
	elif (pos.x < 0):
		return false
	elif (pos.y < 0):
		return false
	return true
