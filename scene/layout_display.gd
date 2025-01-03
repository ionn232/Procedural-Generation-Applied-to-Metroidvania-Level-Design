extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var tileset = tilemap.tile_set

@export var generator: MapGenerator

const empty_atlas = Vector2i(4, 2)
const start_atlas = Vector2i(3, 4)
const gate_Y_atlas = Vector2i(1,3)
const gate_X_atlas = Vector2i(2,3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tilemap.clear()
	var rooms = Utils.rooms
	for column in rooms:
		for room:Room in column:
			if room != null: 
				var current_tilemap_pos:Vector2i = room.grid_pos*2
				var neighbours = get_adjacent_cells(current_tilemap_pos)
				#room content
				if room.data.contains("initial room"):
					tilemap.set_cell(current_tilemap_pos, 0, start_atlas)
				else:
					tilemap.set_cell(current_tilemap_pos, 0, empty_atlas)
				#room neighbours
				tilemap.set_cells_terrain_connect(neighbours, 0, 0)
				var border:Utils.border = Utils.border.UP
				for border_type in room.borders:
					var border_pos = current_tilemap_pos + Utils.border_to_vec2i(border)
					match border_type:
						Utils.border_type.EMPTY:
							tilemap.set_cell(border_pos, 0, empty_atlas)
							pass
						Utils.border_type.LOCKED_DOOR:
							tilemap.set_cell(border_pos, 0, gate_Y_atlas if border == Utils.border.UP || border == Utils.border.DOWN else gate_X_atlas)
							pass
						_:
							pass
					border += 1

func get_adjacent_cells(pos:Vector2i) -> Array[Vector2i]:
	var cells:Array[Vector2i] = []
	cells.resize(8)
	cells[0] = pos + Vector2i(1,0)
	cells[1] = pos + Vector2i(-1,0)
	cells[2] = pos + Vector2i(1,1)
	cells[3] = pos + Vector2i(-1,1)
	cells[4] = pos + Vector2i(-1,-1)
	cells[5] = pos + Vector2i(1,-1)
	cells[6] = pos + Vector2i(0,-1)
	cells[7] = pos + Vector2i(0,1)
	return cells
