class_name Utils
extends Resource

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
	return Vector2i(-5, -5)
