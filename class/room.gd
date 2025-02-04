class_name Room
extends Resource

var grid_pos:Vector2i

#up, down, left, right
var borders:Array[Utils.border_type] = []
var border_data:Array = [] #Array of LockedDoor or Key

#check Utils.room_weights for enum. typed int or null.
var weights:Array = []

var data:String

static var DEBUG_count1 = 0
static var DEBUG_count2 = 0

static func createNew() -> Room:
	var newRoom = Room.new()
	newRoom.borders.resize(4)
	newRoom.border_data.resize(4)
	newRoom.weights.resize(Utils.room_weights.size())
	newRoom.weights.fill(null)
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

#assign a wall type to each direction. Checks map bounds. Ensures parity with adjacent, existing rooms.
func roll_borders_first_pass():
	for direction in Utils.direction.values():
		var direction_vec = Utils.direction_to_vec2i(direction)
		var adjacent_pos = grid_pos + direction_vec

		if (!Utils.is_pos_inside_map(adjacent_pos)):
			borders[direction] = Utils.border_type.WALL
		else:
			var adjacent_room = Level.complete_map.rooms[adjacent_pos.x][adjacent_pos.y]
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
	var new_door = LockedDoor.createNew(keys, Utils.gate_state.LOCKED, Utils.gate_state.TWO_WAY)
	border_data[direction] = new_door

#expand from a room until you reach one with at least 3 exits. O(2n logn), could be made better.
#TODO: if there are no intersections time incrises to O(n^2). Adjust for edge case.
func weight_isolated_memorable() -> int:
	
	if weights[Utils.room_weights.ISOLATED] == 0:
		return 10000
	#alredy computed, save computation cost
	if weights[Utils.room_weights.ISOLATED] != null:
		return weights[Utils.room_weights.ISOLATED]
	
	#mark room as being computed
	weights[Utils.room_weights.ISOLATED] = 0
	var available_directions : Array[Utils.direction]
	available_directions.resize(4)
	var count:int = 0 #number of crossable borders
	
	for direction:Utils.direction in Utils.direction.values():
		if (borders[direction] == Utils.border_type.EMPTY):
			available_directions[count] = direction
			count += 1
	
	#base case
	if (count >= 3 or count == 0):
		weights[Utils.room_weights.ISOLATED] = 1
		return 1
	#recursive case (2 or 1 available directions)
	else:
		var min:int = 1000
		for index in range((count)):
			var direction_vector : Vector2i = Utils.direction_to_vec2i(available_directions[index])
			var next_room = Level.complete_map.rooms[grid_pos.x + direction_vector.x][grid_pos.y + direction_vector.y]
			var next_value = next_room.weight_isolated_memorable()
			min = min(min, next_value)
		return min+1
