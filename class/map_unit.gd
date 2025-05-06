class_name MU
extends Resource

var grid_pos:Vector2i

#up, down, left, right
var borders:Array[Utils.border_type] = []
var border_data:Array[LockedDoor] = [] #Array of LockedDoor or null

var data:String

static var DEBUG_count1 = 0
static var DEBUG_count2 = 0

static func createNew() -> MU:
	var newRoom = MU.new()
	newRoom.borders.resize(4)
	newRoom.border_data.resize(4)
	return newRoom

func assign_borders(up: Utils.border_type, down: Utils.border_type, left: Utils.border_type, right: Utils.border_type): 
	borders[Utils.direction.UP] = up
	borders[Utils.direction.DOWN] = down
	borders[Utils.direction.LEFT] = left
	borders[Utils.direction.RIGHT] = right


func define_pos(pos:Vector2i):
	grid_pos = pos

#might need to do concatenate_data instead
func define_data(newData:String):
	data = newData

#assign a wall type to each direction. Checks map bounds. Ensures parity with adjacent, existing MUs.
func roll_borders_first_pass():
	for direction in Utils.direction.values():
		var direction_vec = Utils.direction_to_vec2i(direction)
		var adjacent_pos = grid_pos + direction_vec

		if (!Utils.is_pos_inside_map(adjacent_pos)):
			borders[direction] = Utils.border_type.WALL
		else:
			var adjacent_room = Level.map.MUs[adjacent_pos.x][adjacent_pos.y]
			if (adjacent_room):
				var adjacent_border = adjacent_room.borders[Utils.opposite_direction(direction)]
				borders[direction] = adjacent_border
			else:
				var roll = randf()
				if roll < 0.75:
					borders[direction] = Utils.border_type.WALL
				else:
					borders[direction] = Utils.border_type.EMPTY

func assign_door(direction: Utils.direction) -> void:
	borders[direction] = Utils.border_type.LOCKED_DOOR
	var keys : Array[Key] = []
	keys.resize(1)
	keys[0] = RewardPool.keySet[0] #TODO: change
	var new_door = LockedDoor.createNew(keys, Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY)
	border_data[direction] = new_door
