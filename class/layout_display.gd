class_name LayoutDisplay
extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var tileset = tilemap.tile_set

@export var generator: MapGenerator

const empty_atlas = Vector2i(4, 2)
const start_atlas = Vector2i(3, 4)
const gate_Y_atlas = Vector2i(1,4)
const gate_X_atlas = Vector2i(2,4)
const wall_X_atlas = Vector2i(0,1)
const wall_Y_atlas = Vector2i(1,0)
const room_inside = Vector2i(3,2)

#TODO: multiples tilemaplayers para modular diferente
const spawn_color = Color(0.1, 0.7, 0.1)
const default_color = Color(1.0 ,1.0 ,1.0)

# Called when the node enters the scene tree for the first time. TODO: render instead of ready when changes can occur
func _ready() -> void:
	var map_grid = Level.map.MUs
	var rooms = Level.rooms
	
	for room:Room in rooms:
		var limits = get_room_limits(room)
		tilemap.set_cells_terrain_connect(limits, 0, 0)
		fill_room_spots(room)
		
		if room.room_type == Utils.room_type.SPAWN:
			self.modulate = spawn_color
		else:
			self.modulate = default_color
		
		for mu:MU in room.room_MUs:
			var current_tilemap_pos:Vector2i = mu.grid_pos*2
			var neighbours = get_adjacent_cells(current_tilemap_pos)
			
			#mu content TODO: loot and saves not ts
			if mu.data.contains("initial room"):
				tilemap.set_cell(current_tilemap_pos, 0, start_atlas)
			else:
				tilemap.set_cell(current_tilemap_pos, 0, empty_atlas)
			
			#connecting grid cells
			var direction:Utils.direction = Utils.direction.UP
			for border_type in mu.borders:
				var border_pos = current_tilemap_pos + Utils.direction_to_vec2i(direction)
				match border_type:
					Utils.border_type.EMPTY:
						tilemap.set_cell(border_pos, 0, empty_atlas)
						pass
					Utils.border_type.SAME_ROOM:
						tilemap.set_cell(border_pos, 0, empty_atlas)
					Utils.border_type.LOCKED_DOOR:
						tilemap.set_cell(border_pos, 0, gate_Y_atlas if direction == Utils.direction.UP || direction == Utils.direction.DOWN else gate_X_atlas)
						pass
					Utils.border_type.WALL:
						tilemap.set_cell(border_pos, 0, wall_Y_atlas if direction == Utils.direction.UP || direction == Utils.direction.DOWN else wall_X_atlas)
					_:
						pass
				direction += 1

#map rendering procedure
func _process(delta: float) -> void:
	pass

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

#gets room delineation cells in tilemap
func get_room_limits(room:Room) -> Array[Vector2i]:
	var cells:Array[Vector2i] = []
	cells.resize(4*room.room_size.x + 4*room.room_size.y + 2)
	var starting_tilemap_pos = room.grid_pos*2 - Vector2i(1,1)
	for i in range(room.room_size.x * 2 + 2):
		cells[i] = starting_tilemap_pos + Vector2i(i, 0)
		cells[room.room_size.x*2 + 1 + i] = starting_tilemap_pos + Vector2i(i, 2*room.room_size.y)
	for j in range(room.room_size.y * 2):
		cells[4 * room.room_size.x + 2 + j] = starting_tilemap_pos + Vector2i(0, j+1)
		cells[4 * room.room_size.x + 2 + room.room_size.y*2 + j] = starting_tilemap_pos + Vector2i(2*room.room_size.x, j+1)
	return cells

#separates MUs with little dots when a room is larger than 2*2
func fill_room_spots(room:Room):
	var starting_tilemap_pos = room.grid_pos*2 + Vector2i(1,1)
	for i in range(room.room_size.x - 1):
		for j in range(room.room_size.y - 1):
			tilemap.set_cell(starting_tilemap_pos + Vector2i(i*2, 0) + Vector2i(0, j*2), 0, room_inside)

func get_room_cells(room:Room) -> Array[Vector2i]:
	return []
