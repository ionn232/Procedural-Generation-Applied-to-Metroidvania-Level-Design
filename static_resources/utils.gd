class_name Utils
extends Resource

enum border_type {
	EMPTY,
	SAME_ROOM,
	WALL,
	DEATH_ZONE,
	LOCKED_DOOR,
}

enum direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

enum reward_type {
	MAIN_UPGRADE,
	SIDE_UPGRADE,
	EQUIPMENT,
	STAT_UPGRADES,
	COLLECTIBLES
}

enum gate_state {
	NON_TRAVERSABLE,
	TRAVERSABLE,
	OPEN,
}

enum gate_directionality {
	TWO_WAY,
	ONE_WAY
}

enum room_type {
	DEFAULT,
	WARP,
	SPAWN
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
	
