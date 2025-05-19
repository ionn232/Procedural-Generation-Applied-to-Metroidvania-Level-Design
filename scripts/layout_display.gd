class_name LayoutDisplay
extends Node2D

@onready var ui: CanvasLayer = $"../UI"

@onready var tilemap_layout: TileMapLayer = $RoomLayout
@onready var tileset_layout = tilemap_layout.tile_set

@onready var tilemap_content: TileMapLayer = $RoomContent
@onready var tileset_content = tilemap_content.tile_set

@export var generator: MapGenerator

const empty_atlas := Vector2i(4, 2)
const full_atlas := Vector2i(5,4)
const start_atlas := Vector2i(3, 4)
const gate_atlas := Vector2i(1,4)
const gate_key_atlas := Vector2i(2,4)
const wall_X_atlas := Vector2i(0,1)
const wall_Y_atlas := Vector2i(1,0)
const room_inside_atlas := Vector2i(3,2)
const gate_up_atlas := Vector2i(5,0)
const gate_down_atlas := Vector2i(5,2)
const gate_left_atlas := Vector2i(5,3)
const gate_right_atlas := Vector2i(5,1)
const gate_key_up_atlas := Vector2i(6,0)
const gate_key_down_atlas := Vector2i(6,2)
const gate_key_left_atlas := Vector2i(6,3)
const gate_key_right_atlas := Vector2i(6,1)

const challenge_room_atlas := Vector2i(0,0)
const save_point_atlas := Vector2i(1,0)
const spawn_point_atlas := Vector2i(2,0)
const main_upgrade_atlas := Vector2i(0,1)
const warp_spot_atlas := Vector2i(1,1)
const key_item_unit_atlas := Vector2i(2,1)
const multiple_items_atlas := Vector2i(0,2)
const side_upgrade_atlas := Vector2i(1,2)
const stat_upgrade_atlas := Vector2i(2,2)
const equipment_atlas := Vector2i(0,3)
const collectible_atlas := Vector2i(1,3)
const shop_atlas := Vector2i(2,3)

#TODO: multiples tilemap_layoutlayers para modular diferente
const trap_color = Color(1.0, 0.4, 0.4)
const default_color = Color(1.0 ,1.0 ,1.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui.stage_changed.connect(_stage_handler.bind())
	pass

func _stage_handler():
	tilemap_content.clear()
	tilemap_layout.clear()
	draw_rooms() #TODO:only when rooms updated
	match(Utils.generator_stage):
		1:
			add_area_nodes()
		11:
			dim_area_nodes()

func add_area_nodes():
	for area:AreaPoint in Level.area_points:
		add_child(area, true)

func dim_area_nodes():
	for area:AreaPoint in Level.area_points:
		area.set_point_color(Utils.area_colors[area.area_index] * Color(1,1,1, 0.4))

func draw_rooms(): #TODO: multiple tilemaplayers for layouts and content to modulate colors. COLOR BY AREAS OR BY STEPS || RENDER BY STEPS (input index)
	var map_grid = Level.map.MUs
	var rooms = Level.rooms
	for room:Room in rooms:
		var limits:Array[Vector2i] = get_room_limits(room)
		tilemap_layout.set_cells_terrain_connect(limits, 0, 0)
		fill_room_spots(room)
		
		#TODO: room type, is trap modulate
		for mu:MU in room.room_MUs:
			var current_tilemap_layout_pos:Vector2i = mu.grid_pos*2
			#mu type
			match(mu):
				_ when mu.is_spawn:
					tilemap_content.set_cell(mu.grid_pos, 0, spawn_point_atlas)
				_ when mu.is_save:
					tilemap_content.set_cell(mu.grid_pos, 0, save_point_atlas)
				_ when mu.is_fast_travel:
					tilemap_content.set_cell(mu.grid_pos, 0, warp_spot_atlas)
				_ when mu.is_shop: 
					tilemap_content.set_cell(mu.grid_pos, 0, shop_atlas)
			
			#mu content
			if len(mu.rewards) == 1:
				match mu.rewards[0]:
					_ when mu.rewards[0] is MainUpgrade:
						tilemap_content.set_cell(mu.grid_pos, 0, main_upgrade_atlas)
					_ when mu.rewards[0] is KeyItemUnit:
						tilemap_content.set_cell(mu.grid_pos, 0, key_item_unit_atlas)
					_ when mu.rewards[0] is SideUpgrade:
						tilemap_content.set_cell(mu.grid_pos, 0, side_upgrade_atlas)
					#TODO stat upgrades, equipment, collectibles
			
			#room borders
			for direction:Utils.direction in range(4):
				var border_pos = current_tilemap_layout_pos + Utils.direction_to_vec2i(direction)
				if border_pos in limits:
					match mu.borders[direction]:
						Utils.border_type.EMPTY:
							tilemap_layout.set_cell(border_pos, 0, empty_atlas)
						Utils.border_type.SAME_ROOM: #shouldnt happen
							print('WARNING: error in layout display')
							tilemap_layout.set_cell(border_pos, 0, empty_atlas)
						Utils.border_type.LOCKED_DOOR:
							var has_key:bool = len(mu.border_data[direction].keyset) >= 1
							if mu.border_data[direction].directionality == Utils.gate_directionality.TWO_WAY:
								tilemap_layout.set_cell(border_pos, 0, gate_atlas if !has_key else gate_key_atlas)
							else:
								tilemap_layout.set_cell(border_pos, 0, get_direction_oneway_atlas(direction, has_key))
						Utils.border_type.WALL:
							tilemap_layout.set_cell(border_pos, 0, wall_Y_atlas if direction == Utils.direction.UP || direction == Utils.direction.DOWN else wall_X_atlas)

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

#gets room delineation cells in tilemap_layout
func get_room_limits(room:Room) -> Array[Vector2i]:
	var cells:Array[Vector2i] = []
	cells.resize(4*room.room_size.x + 4*room.room_size.y + 2)
	var starting_tilemap_layout_pos = room.grid_pos*2 - Vector2i(1,1)
	for i in range(room.room_size.x * 2 + 1):
		cells[i] = starting_tilemap_layout_pos + Vector2i(i, 0)
		cells[room.room_size.x*2 + 1 + i] = starting_tilemap_layout_pos + Vector2i(i, 2*room.room_size.y)
	for j in range(room.room_size.y * 2):
		cells[4 * room.room_size.x + 2 + j] = starting_tilemap_layout_pos + Vector2i(0, j+1)
		cells[4 * room.room_size.x + 2 + room.room_size.y*2 + j] = starting_tilemap_layout_pos + Vector2i(2*room.room_size.x, j+1)
	return cells


func fill_room_spots(room:Room):
	var starting_tilemap_layout_pos = room.grid_pos*2
	for i in range(room.room_size.x*2 - 1):
		for j in range(room.room_size.y*2 - 1):
			var current_tilemap_layout_pos = starting_tilemap_layout_pos + Vector2i(i, 0) + Vector2i(0, j)
			tilemap_layout.set_cell(current_tilemap_layout_pos, 0, empty_atlas)

func get_direction_oneway_atlas(direction:Utils.direction, has_key:bool = false):
	match direction:
		Utils.direction.UP:
			return gate_up_atlas if !has_key else gate_key_up_atlas
		Utils.direction.DOWN:
			return gate_down_atlas if !has_key else gate_key_down_atlas
		Utils.direction.LEFT:
			return gate_left_atlas if !has_key else gate_key_left_atlas
		Utils.direction.RIGHT:
			return gate_right_atlas if !has_key else gate_key_right_atlas
			
