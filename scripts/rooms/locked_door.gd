class_name LockedDoor
extends Resource

var keyset : Array[Reward] = []
var state : Utils.gate_state = Utils.gate_state.NON_TRAVERSABLE
var final_state : Utils.gate_state = Utils.gate_state.TRAVERSABLE
var directionality : Utils.gate_directionality = Utils.gate_directionality.TWO_WAY
var direction = null #ONLY USED FOR ONE-WAYS, type:Utils.direction
var is_protected:bool = false #avoid overwriting to conserve paths when connecting rooms

static func createNew(final_state:Utils.gate_state, directionality:Utils.gate_directionality, gate_direction = null, keys:Array[Reward] = []) -> LockedDoor:
	var new_door = LockedDoor.new()
	new_door.keyset = keys
	new_door.state = Utils.gate_state.NON_TRAVERSABLE
	new_door.final_state = final_state
	new_door.directionality = directionality
	if gate_direction != null: new_door.direction = gate_direction
	return new_door

func set_direction(new_direction:Utils.direction):
	self.direction = new_direction
