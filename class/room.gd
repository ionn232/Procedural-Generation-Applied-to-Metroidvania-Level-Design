class_name Room
extends Resource

#upper leftmost MU dictates room position
var grid_pos:Vector2i

#room dimensions
var room_size:Vector2i

#MUs comprising the room
var room_MUs : Array[MU] = []

var room_type:Utils.room_type = Utils.room_type.DEFAULT

static func createNew(size:Vector2i) -> Room:
	var newRoom = Room.new()
	newRoom.room_size = size
	newRoom.room_MUs.resize(size.x * size.y)
	return newRoom

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
			Level.map.MUs[newPos.x][newPos.y] = new_MU
			add_MU(new_MU, i*room_size.y+j)

func define_pos(pos:Vector2i):
	grid_pos = pos

func define_type(newType:Utils.room_type):
	room_type = newType

func add_MU(newMU:MU, index:int = 0):
	room_MUs[index] = newMU
