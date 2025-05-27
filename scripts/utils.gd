class_name Utils
extends Resource

static var generator_stage : int = 0
static var rng : RandomNumberGenerator = RandomNumberGenerator.new()
static var ROOM_SIZE:float = 16.0

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

const area_colors : Array[Color] = [
	Color.RED,
	Color.BLUE,
	Color.YELLOW,
	Color.PURPLE,
	Color.GREEN,
	Color.ORANGE,
	Color.LIGHT_PINK,
	Color.AQUA,
	Color.MAGENTA,
	Color.BEIGE,
	Color.SKY_BLUE,
	Color.MAROON,
	Color.NAVY_BLUE,
	Color.FUCHSIA,
	Color.OLIVE,
	Color.DARK_SLATE_BLUE,
	Color.BROWN,
	Color.TEAL,
	Color.DARK_GREEN,
	Color.GOLD,
	Color.INDIGO,
	Color.SILVER,
	Color.DARK_ORANGE,
	Color.DARK_TURQUOISE,
	Color.CRIMSON
]

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

static func vec2i_to_direction(input:Vector2i) -> direction:
	match input:
		Vector2i(0,-1):
			return direction.UP
		Vector2i(0,1):
			return direction.DOWN
		Vector2i(-1,0):
			return direction.LEFT
		Vector2i(1,0):
			return direction.RIGHT
	print('❌ ERROR converting vec2i to direction: input value -> ', input)
	return 0

static func opposite_direction(dir:direction) -> direction:
	match dir:
		direction.UP:
			return direction.DOWN
		direction.DOWN:
			return direction.UP
		direction.LEFT:
			return direction.RIGHT
		direction.RIGHT:
			return direction.LEFT
	print('❌ ERROR converting direction to opposite: input value -> ', dir)
	return direction.UP

static func is_pos_inside_map(pos:Vector2i) -> bool:
	if (pos.x > Level.map_size_x/2.0 - 1):
		return false
	elif (pos.y > Level.map_size_y/2.0 - 1):
		return false
	elif (pos.x < -Level.map_size_x/2.0):
		return false
	elif (pos.y < -Level.map_size_y/2.0):
		return false
	return true
	
static func room_index_to_world(index:int) -> int:
	return index*16
static func room_pos_to_world(pos:Vector2i) -> Vector2i:
	return pos * 16
static func world_pos_to_room(world_pos:Vector2) -> Vector2i:
	return Vector2i(round((world_pos.x-4)/16.0), round((world_pos.y-4)/16.0))  
static func absolute_direction(pos1:Vector2i, pos2:Vector2i) -> Vector2i:
	var direction_vec:Vector2i
	var step1:Vector2i = (pos2-pos1)
	var step2:Vector2i = step1.abs()
	direction_vec[step2.max_axis_index()] = 1 * sign(step1[step2.max_axis_index()])
	return direction_vec
