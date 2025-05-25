class_name MU
extends Resource

var grid_pos:Vector2i

var parent_room:Room

#up, down, left, right
var borders:Array[Utils.border_type] = []
var border_data:Array[LockedDoor] = [] #Array of LockedDoor or null, index parity with borders

var rewards:Array

var is_spawn:bool = false
var is_save:bool = false
var is_fast_travel:bool = false
var is_shop:bool = false
var is_minor_boss:bool = false
var is_major_boss:bool = false

var minor_reward_score:int = -1
#-1||0 -> not viable
#1 -> viable

static func createNew() -> MU:
	var new_map_unit = MU.new()
	new_map_unit.borders.resize(4)
	new_map_unit.border_data.resize(4)
	return new_map_unit

func assign_borders(up: Utils.border_type, down: Utils.border_type, left: Utils.border_type, right: Utils.border_type): 
	borders[Utils.direction.UP] = up
	borders[Utils.direction.DOWN] = down
	borders[Utils.direction.LEFT] = left
	borders[Utils.direction.RIGHT] = right


func define_pos(pos:Vector2i):
	grid_pos = pos

func add_reward(new_reward:Reward):
	rewards.push_back(new_reward)

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
	#var keys : Array[Key] = []
	#keys.resize(1)
	#keys[0] = RewardPool.keyset[0] #TODO: change
	var new_door = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY)
	border_data[direction] = new_door
