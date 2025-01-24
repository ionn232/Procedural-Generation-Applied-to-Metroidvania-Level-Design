class_name LockedDoor
extends Resource

var keyset : Array[Key] = []
var state : Utils.gate_state = Utils.gate_state.LOCKED

# Always two positions.
# [0]: player obtains associated key, [1]: player crosses it for the first time
# if null, no transformation occurs
var transformation_table: Array[Utils.gate_state] = []

static func createNew(keys:Array[Key], initial_state:Utils.gate_state, first:Utils.gate_state, second = null) -> LockedDoor:
	var new_door = LockedDoor.new()
	new_door.keyset = keys
	new_door.state = initial_state
	new_door.transformation_table.resize(2)
	new_door.transformation_table[0] = first
	new_door.transformation_table[1] = second
	return new_door
