class_name traversableArea
extends Resource

#TODO: improve shitty DFS implementation using better algorithm
#TODO: consider gates with an input key list
func exists_path(pos0:Vector2i, pos1:Vector2i) -> bool:
	var rooms = Map.rooms
	var queue : Array[Room] = []
	
	if (!(is_room_valid(pos0) && is_room_valid(pos1))):
		print('❌ ERROR invalid position(s) at method traversableArea.exists_path for coords: ', pos0, pos1)
		return false
	
	while (queue.front() != null):
		var current_room:Room = queue.pop_front()
		if (current_room.grid_pos == pos1):
			return true
		else:
			for direction in Utils.direction.values():
				var wall_type = current_room.borders[direction]
				if (wall_type == Utils.border_type.WALL):
					var direction_vec = Utils.border_to_vec2i(direction)
					var adjacent_pos = current_room.grid_pos + direction_vec
					queue.push_back(Map.rooms[adjacent_pos.x][adjacent_pos.y])
	return false

func is_room_valid(pos:Vector2i) -> bool:
	if (!Utils.is_pos_inside_map(pos)):
		return false
	if (!Map.rooms[pos.x][pos.y]):
		return false
	return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
