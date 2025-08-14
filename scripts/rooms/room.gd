class_name Room
extends Resource

var area_index:int
var step_index:int
var associated_point:Point = null

#upper leftmost MU dictates room position
var grid_pos:Vector2i

#room dimensions
var room_size:Vector2i

#MUs comprising the room
var room_MUs : Array[MU] = []

#room type
var is_trap:bool = false
var is_main_route_location:bool = false

var minor_rewards_viable:bool = false

static func createNew(pos:Vector2i, area_i:int, step_i:int, size:Vector2i = Vector2i(1,1), point:Point = null) -> Room:
	var newRoom = Room.new()
	newRoom.grid_pos = pos
	newRoom.room_size = size
	newRoom.room_MUs.resize(size.x * size.y)
	
	newRoom.area_index = area_i
	newRoom.step_index = step_i
	if (point != null):
		newRoom.associated_point = point
	
	newRoom.createRoomMUs()
	Level.rooms.push_back(newRoom)
	
	return newRoom

static func canCreate(pos:Vector2i, size:Vector2i = Vector2i(1,1), origin_point:Point = null) -> bool:
	if size.x == 0 && size.y == 0: return false #uninitialized room
	elif pos.x + (size.x-1) > ((Level.map_size_x)/2 - int(Level.map_size_x%2==0)) || pos.x < -(Level.map_size_x)/2: return false #out of bounds - x
	elif pos.y + (size.y-1) > ((Level.map_size_y)/2 - int(Level.map_size_y%2==0)) || pos.y < -(Level.map_size_y)/2: return false #out of bounds - y
	
	#check if MU exists in this position already.
	#if origin_point != null:
		#var point_mu:MU = Level.map.get_mu_at(Utils.world_pos_to_room(origin_point.global_position))
		#if point_mu != null: #This mu is alredy occupied by another room. Move point.
			#var new_position:Vector2 = origin_point.pos + Vector2(Utils.rng.randf_range(1.0, 2.0) * 16, Utils.rng.randf_range(1.0, 2.0) * 16)
			#origin_point.update_position(new_position) #16 -> room size TODO make global
			#return false #create room next iteration
	
	var current_pos:Vector2i
	for i in range(size.x):
		for j in range(size.y):
				current_pos = Vector2i(pos.x + i, pos.y + j)
				if Level.map.get_mu_at(current_pos) != null: return false
	return true

func createRoomMUs():
	for i:int in range(room_size.x):
		for j:int in range(room_size.y):
			var new_MU = MU.createNew()
			var newPos:Vector2i = grid_pos + Vector2i(i, j)
			new_MU.define_pos(newPos)
			new_MU.assign_borders(
				Utils.border_type.WALL if j==0 else Utils.border_type.SAME_ROOM, 
				Utils.border_type.WALL if j==room_size.y-1 else Utils.border_type.SAME_ROOM, 
				Utils.border_type.WALL if i==0 else Utils.border_type.SAME_ROOM, 
				Utils.border_type.WALL if i==room_size.x-1 else Utils.border_type.SAME_ROOM,
				)
			new_MU.parent_room = self
			Level.map.MUs[newPos.x][newPos.y] = new_MU
			add_MU(new_MU, i*room_size.y+j)

func get_mu_towards(direction:Utils.direction) -> MU:
	match(direction):
		Utils.direction.UP:
			return Level.map.get_mu_at(grid_pos + Vector2i(Utils.rng.randi_range(0, room_size.x-1), 0))
		Utils.direction.DOWN:
			return Level.map.get_mu_at(grid_pos + Vector2i(Utils.rng.randi_range(0, room_size.x-1), room_size.y-1))
		Utils.direction.LEFT:
			return Level.map.get_mu_at(grid_pos + Vector2i(0, Utils.rng.randi_range(0, room_size.y-1)))
		Utils.direction.RIGHT:
			return Level.map.get_mu_at(grid_pos + Vector2i(room_size.x-1, Utils.rng.randi_range(0, room_size.y-1)))
	print('invalid direction given!!')
	return null

func get_adjacent_free_MU_pos(): #return type: Vector2i || null
	var adjacent_mu:MU
	var adjacent_mu_pos:Vector2i
	for room_mu:MU in self.room_MUs:
		for direction:Utils.direction in range(4):
			if room_mu.borders[direction] == Utils.border_type.LOCKED_DOOR || room_mu.borders[direction] == Utils.border_type.SAME_ROOM:
				continue
			adjacent_mu_pos = room_mu.grid_pos + Utils.direction_to_vec2i(direction)
			if !Utils.is_pos_inside_map(adjacent_mu_pos): 
				continue
			adjacent_mu = Level.map.get_mu_at(adjacent_mu_pos)
			if adjacent_mu == null: 
				return adjacent_mu_pos
	return null

func get_random_viable_reward_MU() -> MU:
	if !minor_rewards_viable: return null
	var selected_mu:MU = null
	while selected_mu == null:
		selected_mu = room_MUs[Utils.rng.randi_range(0, len(room_MUs)-1)]
		if selected_mu.minor_reward_score != 1: selected_mu = null
	return selected_mu

func define_pos(pos:Vector2i):
	grid_pos = pos

func add_MU(newMU:MU, index:int = 0):
	room_MUs[index] = newMU

func mimic_adjacent_rooms_area():
	var seen_rooms:Array[Room]
	var target_pos:Vector2i
	var target_mu:MU
	var target_room:Room
	var initial_area_index:int = self.area_index
	var area_counts:Dictionary = {}
	area_counts[self.area_index] = 0
	#get adjacent rooms
	for current_mu:MU in self.room_MUs:
		for direction:Utils.direction in range(4):
			if current_mu.borders[direction] == Utils.border_type.SAME_ROOM: continue
			target_pos = current_mu.grid_pos + Utils.direction_to_vec2i(direction)
			if !Utils.is_pos_inside_map(target_pos): continue
			target_mu = Level.map.get_mu_at(target_pos)
			if target_mu != null:
				if !Utils.is_pos_inside_map(target_mu.grid_pos): continue
				target_room = target_mu.parent_room
				if seen_rooms.has(target_room): continue
				seen_rooms.push_back(target_room)
				if !area_counts.has(target_room.area_index):
					area_counts[target_room.area_index] = 1
				else:
					area_counts[target_room.area_index] += 1
	#reassign area if more adjacent rooms of other area exist
	for adjacent_area_index:int in area_counts.keys():
		if adjacent_area_index == self.area_index: continue
		if area_counts[adjacent_area_index] > area_counts[self.area_index] || area_counts[adjacent_area_index] > 2:
			self.area_index = adjacent_area_index
			#reassign seen rooms if they are the previous area index as results can change
			for prev_area_adjacent_room:Room in seen_rooms.filter(func(val:Room): return val.area_index == initial_area_index):
				prev_area_adjacent_room.mimic_adjacent_rooms_area()
			return

enum relation_type {
	NON_ADJACENT,
	ADJACENT,
	OVERLAP,
}

func is_adjacent_to(other_room:Room) -> bool:
	var x_mode:relation_type
	var y_mode:relation_type
	var x_difference:int = 0
	var y_difference:int = 0
	#x difference
	if other_room.grid_pos.x < self.grid_pos.x:
		x_difference = self.grid_pos.x - (other_room.grid_pos.x + other_room.room_size.x - 1)
	else:
		x_difference = other_room.grid_pos.x - (self.grid_pos.x + self.room_size.x - 1)
	#x relation
	match (x_difference):
		1:
			x_mode = relation_type.ADJACENT
		_ when x_difference <= 0:
			x_mode = relation_type.OVERLAP
		_ when x_difference > 1:
			x_mode = relation_type.NON_ADJACENT
	#y difference
	if other_room.grid_pos.y < self.grid_pos.y:
		y_difference = self.grid_pos.y - (other_room.grid_pos.y + other_room.room_size.y - 1)
	else:
		y_difference = other_room.grid_pos.y - (self.grid_pos.y + self.room_size.y - 1)
	#y relation
	match (y_difference):
		1:
			y_mode = relation_type.ADJACENT
		_ when y_difference <= 0:
			y_mode = relation_type.OVERLAP
		_ when y_difference > 1:
			y_mode = relation_type.NON_ADJACENT
	#result computation
	return (
		x_mode == relation_type.OVERLAP && y_mode == relation_type.ADJACENT
		||
		x_mode == relation_type.ADJACENT && y_mode == relation_type.OVERLAP
	)
	
func get_random_MU() -> MU:
	return self.room_MUs[Utils.rng.randi_range(0, len(self.room_MUs)-1)]

func get_free_MU() -> MU: #Excludes save points! (avoid crashes) #TODO make random
	for room_mu:MU in self.room_MUs:
		if len(room_mu.rewards) == 0 && !room_mu.is_fast_travel && !room_mu.is_shop && !room_mu.is_spawn:
			return room_mu
	return null
