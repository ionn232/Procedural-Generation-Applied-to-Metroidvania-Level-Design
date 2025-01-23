class_name Room
extends Resource

var grid_pos:Vector2i

#up, down, left, right
var borders:Array[Utils.border_type] = []
var border_data:Array = [] #Array of LockedDoor or Key

var data:String


func assign_borders(up: Utils.border_type, down: Utils.border_type, left: Utils.border_type, right: Utils.border_type): 
	borders[Utils.direction.UP] = up
	borders[Utils.direction.DOWN] = down
	borders[Utils.direction.LEFT] = left
	borders[Utils.direction.RIGHT] = right


func define_data(pos:Vector2i, input_data: String):
	borders.resize(4)
	grid_pos = pos
	data = input_data

#assign a wall type to each direction. Checks map bounds. Ensures parity with adjacent, existing rooms.
func roll_borders():
	for direction in Utils.direction.values():
		var direction_vec = Utils.border_to_vec2i(direction)
		var adjacent_pos = grid_pos + direction_vec

		if (!Utils.is_pos_inside_map(adjacent_pos)):
			borders[direction] = Utils.border_type.WALL
		else:
			var adjacent_room = Level.complete_map.rooms[adjacent_pos.x][adjacent_pos.y]
			if (adjacent_room):
				var adjacent_border = adjacent_room.borders[Utils.opposite_direction(direction)]
				borders[direction] = adjacent_border
				print('direction: ', direction, ' // adjacent direction type: ', adjacent_border)
			#TODO: change behaviour
			else:
				var roll = randf()
				if roll < 0.6:
					borders[direction] = Utils.border_type.WALL
				#elif roll < 0.65:
					#borders[direction] = Utils.border_type.LOCKED_DOOR
				else:
					borders[direction] = Utils.border_type.EMPTY
