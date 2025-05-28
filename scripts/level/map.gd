class_name Map
extends Resource

var MUs:Array[Array] = []

func initialize_map():
	MUs.resize(0)
	MUs.resize(Level.map_size_x)
	for i in MUs.size():
		var room_column:Array[MU] = []
		room_column.resize(Level.map_size_y)
		room_column.fill(null)
		MUs[i] = room_column

func get_mu_at(position:Vector2i) -> MU:
	return MUs[position.x][position.y]
