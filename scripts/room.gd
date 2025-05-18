class_name Room
extends Resource

var area_index:int
var step_index:int

#upper leftmost MU dictates room position
var grid_pos:Vector2i

#room dimensions
var room_size:Vector2i

#MUs comprising the room
var room_MUs : Array[MU] = []

#room types
var is_trap:bool = false

static func createNew(pos:Vector2i, area_i:int, size:Vector2i = Vector2i(1,1)) -> Room:
	var newRoom = Room.new()
	newRoom.grid_pos = pos
	newRoom.room_size = size
	newRoom.room_MUs.resize(size.x * size.y)
	Level.rooms.push_back(newRoom)
	return newRoom

static func canCreate(pos:Vector2i, size:Vector2i = Vector2i(1,1)) -> bool:
	if size.x == 0 && size.y == 0: return false #uninitialized room
	elif pos.x + size.x > Level.map_size_x/2 || pos.x < -Level.map_size_x/2: return false #out of bounds - x
	elif pos.y + size.y > Level.map_size_y/2 || pos.y < -Level.map_size_y/2: return false #out of bounds - y
	
	var current_pos:Vector2i
	for i in range(size.x):
		for j in range(size.y):
				current_pos = Vector2i(pos.x + i, pos.y + j)
				if Level.map.get_mu_at(current_pos) != null: return false
	return true

func createRoomMUs():
	for i:int in range(room_size.x):
		for j:int in range(room_size.y):
			var new_MU = MU.createNew()
			var newPos:Vector2i = grid_pos + Vector2i(i, j)
			new_MU.define_pos(newPos)
			new_MU.assign_borders(
				Utils.border_type.WALL if j==0 else Utils.border_type.SAME_ROOM, 
				Utils.border_type.WALL if j==room_size.y-1 else Utils.border_type.SAME_ROOM, 
				Utils.border_type.WALL if i==0 else Utils.border_type.SAME_ROOM, 
				Utils.border_type.WALL if i==room_size.x-1 else Utils.border_type.SAME_ROOM,
				)
			new_MU.parent_room = self
			Level.map.MUs[newPos.x][newPos.y] = new_MU
			add_MU(new_MU, i*room_size.y+j)

func get_mu_towards(direction:Utils.direction) -> MU:
	match(direction):
		Utils.direction.UP:
			return Level.map.get_mu_at(grid_pos + Vector2i(Utils.rng.randi_range(0, room_size.x-1), 0))
		Utils.direction.DOWN:
			return Level.map.get_mu_at(grid_pos + Vector2i(Utils.rng.randi_range(0, room_size.x-1), room_size.y-1))
		Utils.direction.LEFT:
			return Level.map.get_mu_at(grid_pos + Vector2i(0, Utils.rng.randi_range(0, room_size.y-1)))
		Utils.direction.RIGHT:
			return Level.map.get_mu_at(grid_pos + Vector2i(room_size.x-1, Utils.rng.randi_range(0, room_size.y-1)))
	print('invalid direction given!!')
	return null
	

func define_pos(pos:Vector2i):
	grid_pos = pos

func add_MU(newMU:MU, index:int = 0):
	room_MUs[index] = newMU
