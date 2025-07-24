class_name LayoutDisplay
extends Node2D

@onready var ui: CanvasLayer = $"../UI"


@onready var tilemap_content: TileMapLayer = $RoomContent
@onready var tilemap_bg: TileMapLayer = $Background
@onready var room_layout_container: Node2D = $RoomLayoutContainer

var step_display_cap:int = 9999

var layout_tilemaps:Array[TileMapLayer]

const ROOM_LAYOUT = preload("res://scene/tilemaplayers/room_layout.tscn")

const wall_up_atlas := Vector2i(1,0)
const wall_down_atlas := Vector2i(1,2)
const wall_left_atlas := Vector2i(0,1)
const wall_right_atlas := Vector2i(2,1)

const wall_up_slim_atlas := Vector2i(8,0)
const wall_down_slim_atlas := Vector2i(8,2)
const wall_left_slim_atlas := Vector2i(7,1)
const wall_right_slim_atlas := Vector2i(9,1)

const empty_atlas := Vector2i(4, 2)
const trap_atlas := Vector2i(4,3)
const full_atlas := Vector2i(5,4)
const start_atlas := Vector2i(3, 4)
const gate_x_atlas := Vector2i(1,4)
const gate_y_atlas := Vector2i(2,4)
const gate_x_key_atlas := Vector2i(3,4)
const gate_y_key_atlas := Vector2i(4,4)
const room_inside_atlas := Vector2i(3,2)
const gate_up_atlas := Vector2i(5,0)
const gate_down_atlas := Vector2i(5,2)
const gate_left_atlas := Vector2i(5,3)
const gate_right_atlas := Vector2i(5,1)
const gate_key_up_atlas := Vector2i(6,0)
const gate_key_down_atlas := Vector2i(6,2)
const gate_key_left_atlas := Vector2i(6,3)
const gate_key_right_atlas := Vector2i(6,1)

const bg_atlas := Vector2i(3, 0)
const trap_bg_atlas := Vector2i(3,1)
const major_boss_atlas := Vector2i(0,0)
const minor_boss_atlas := Vector2i(3, 2)
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

const trap_color = Color(1.0, 0.4, 0.4)
const default_color = Color(1.0 ,1.0 ,1.0)

func change_step_display_limit(new_max_step:int):
	step_display_cap = new_max_step
	clear_tilemaps()
	draw_rooms()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui.stage_changed.connect(_stage_handler.bind())
	ui.max_step_selected.connect(change_step_display_limit.bind())
	layout_tilemaps.resize(Level.num_areas+1)
	var new_tilemap_layout = ROOM_LAYOUT.instantiate()
	layout_tilemaps[0] = new_tilemap_layout
	room_layout_container.add_child(new_tilemap_layout, true)
	for i:int in range(Level.num_areas):
		new_tilemap_layout = ROOM_LAYOUT.instantiate()
		new_tilemap_layout.modulate = Utils.area_colors[i]
		layout_tilemaps[i+1] = new_tilemap_layout
		room_layout_container.add_child(new_tilemap_layout, true)

func reset():
	clear_tilemaps()

func clear_tilemaps():
	tilemap_content.clear()
	tilemap_bg.clear()
	for i:int in range(Level.num_areas + 1):
		layout_tilemaps[i].clear()

func _stage_handler():
	clear_tilemaps()
	draw_rooms()

func add_area_nodes():
	for area:AreaPoint in Level.area_points:
		add_child(area, true)

func dim_area_nodes():
	for area:AreaPoint in Level.area_points:
		area.set_point_color(Utils.area_colors[area.area_index] * Color(1,1,1, 0.4))

func draw_rooms():
	var rooms = Level.rooms
	for room:Room in rooms:
		#skip steps over current visualized limit
		if room.step_index > step_display_cap && !(room.is_main_route_location && room.step_index-1 == step_display_cap): continue
		var limits:Array[Vector2i] = get_room_limits(room)
		draw_room_bg(room, room.is_trap)
		#draw layout
		layout_tilemaps[room.area_index+1].set_cells_terrain_connect(limits, 0, 0)
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
				_ when mu.is_minor_boss: 
					tilemap_content.set_cell(mu.grid_pos, 0, minor_boss_atlas)
				_ when mu.is_major_boss: 
					tilemap_content.set_cell(mu.grid_pos, 0, major_boss_atlas)
			#shitty hack for a few edge cases
			if mu.is_save && (mu.is_spawn || mu.is_fast_travel || mu.is_shop || mu.is_minor_boss || mu.is_major_boss):
				tilemap_content.set_cell(mu.grid_pos, 0, multiple_items_atlas)
			
			#mu content
			if len(mu.rewards) == 1:
				match mu.rewards[0]:
					_ when mu.is_major_boss || mu.is_minor_boss:
						tilemap_content.set_cell(mu.grid_pos, 0, multiple_items_atlas)
					_ when mu.rewards[0] is MainUpgrade:
						tilemap_content.set_cell(mu.grid_pos, 0, main_upgrade_atlas)
					_ when mu.rewards[0] is KeyItemUnit:
						tilemap_content.set_cell(mu.grid_pos, 0, key_item_unit_atlas)
					_ when mu.rewards[0] is SideUpgrade:
						tilemap_content.set_cell(mu.grid_pos, 0, side_upgrade_atlas)
					_ when mu.rewards[0] is Equipment:
						tilemap_content.set_cell(mu.grid_pos, 0, equipment_atlas)
					_ when mu.rewards[0] is Collectible:
						tilemap_content.set_cell(mu.grid_pos, 0, collectible_atlas)
					_ when mu.rewards[0] is StatUpgrade:
						tilemap_content.set_cell(mu.grid_pos, 0, stat_upgrade_atlas)
			elif len(mu.rewards) > 1:
				tilemap_content.set_cell(mu.grid_pos, 0, multiple_items_atlas)
			
			#room borders
			for direction:Utils.direction in range(4):
				var border_pos = current_tilemap_layout_pos + Utils.direction_to_vec2i(direction)
				if border_pos in limits:
					match mu.borders[direction]:
						Utils.border_type.EMPTY:
							layout_tilemaps[room.area_index+1].set_cell(border_pos, 0, empty_atlas)
						Utils.border_type.SAME_ROOM: #shouldnt happen
							print('WARNING: error in layout display')
							layout_tilemaps[room.area_index+1].set_cell(border_pos, 0, empty_atlas)
						Utils.border_type.LOCKED_DOOR:
							var has_key:bool = len(mu.border_data[direction].keyset) >= 1
							if mu.border_data[direction].directionality == Utils.gate_directionality.TWO_WAY:
								var selected_atlas:Vector2i = (gate_y_atlas if !has_key else gate_y_key_atlas) if direction > 1 else (gate_x_atlas if !has_key else gate_x_key_atlas)
								layout_tilemaps[room.area_index+1].set_cell(border_pos, 0, selected_atlas)
							else:
								layout_tilemaps[room.area_index+1].set_cell(border_pos, 0, get_direction_oneway_atlas(mu.border_data[direction].direction, has_key))
						#Utils.border_type.WALL:
							#layout_tilemaps[room.area_index+1].set_cell(border_pos, 0, direction_to_wall_atlas(direction))

func direction_to_wall_atlas(direction:Utils.direction) -> Vector2i:
	match direction:
		Utils.direction.UP:
			return wall_up_atlas
		Utils.direction.DOWN:
			return wall_down_atlas
		Utils.direction.LEFT:
			return wall_left_atlas
		Utils.direction.RIGHT:
			return wall_right_atlas
	print('direction to wall error!"!!')
	return empty_atlas

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

func draw_room_bg(room:Room, is_trap_room:bool):
	for mu:MU in room.room_MUs:
		tilemap_bg.set_cell(mu.grid_pos, 0, bg_atlas if !is_trap_room else trap_bg_atlas)

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
