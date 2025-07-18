class_name traversableArea
extends Resource

#TODO: improve shitty DFS implementation using better algorithm
#TODO: consider gates with an input key list
#TODO: optimize seen array by removing dynamic memory allocation
static func exists_path(pos0:Vector2i, pos1:Vector2i) -> bool:
	var MUs = Level.map.MUs
	var queue : Array[MU] = []
	var seen : Array[MU] = []
	
	if (!(_is_room_valid(MUs, pos0) && _is_room_valid(MUs, pos1))):
		print('❌ ERROR invalid position(s) at method traversableArea.exists_path for coords: ', pos0, pos1)
		return false
	
	queue.push_back(MUs[pos0.x][pos0.y])
	
	while (queue.front() != null):
		var current_room:MU = queue.pop_front()
		if (current_room.grid_pos == pos1):
			return true
		else:
			for direction in Utils.direction.values():
				var wall_type = current_room.borders[direction]
				if (wall_type == Utils.border_type.EMPTY && seen.find(current_room) == -1 ):
					var direction_vec = Utils.direction_to_vec2i(direction)
					var adjacent_pos = current_room.grid_pos + direction_vec
					queue.push_back(MUs[adjacent_pos.x][adjacent_pos.y])
		seen.push_back(current_room)
	return false

#internal use only. Do not call outside traversableArea script.
#TODO: como coño se hace una funcion privada
static func _is_room_valid(MUs: Array[Array],pos:Vector2i) -> bool:
	if (!Utils.is_pos_inside_map(pos)):
		return false
	if (!MUs[pos.x][pos.y]):
		return false
	return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
