extends Node

@onready var common: Node2D = $"../Common"

func execute(): ##Distribute minor rewards
	#initialize necessary data structure
	Level.minor_reward_room_counts.resize(Level.num_route_steps)
	for step_i:int in Level.num_route_steps:
		Level.minor_reward_room_counts[step_i].push_back([])
	for room:Room in Level.rooms:
		#add room to pool of possible reward containers
		if room.minor_rewards_viable:
			#initialize array if necessary
			Level.minor_reward_room_counts[min(room.step_index, Level.num_route_steps-1)][0].push_back(room)
	
	var current_reward:Reward
	var step_minor_rewards:Array
	var num_backtracking_rewards:int
	var num_exploration_rewards:int
	var selected_room:Room
	var potential_room
	var selected_mu:MU
	var existing_room_reward_count:int
	var random_index:int
	var new_room_mu_pos #Type: Vector2i || null
	var new_room:Room
	var new_room_gate:LockedDoor
	var no_rooms_available:bool = false
	for step:RouteStep in Level.route_steps:
		step_minor_rewards = step.get_minor_rewards()
		Utils.array_shuffle(step_minor_rewards)
		#partition exploration and backtracking rewards unless initial step
		num_backtracking_rewards = len(step_minor_rewards) * Level.backtracking_factor if step.index > 0 else 0
		num_exploration_rewards = len(step_minor_rewards) - num_backtracking_rewards
		#edge case: no viable rooms for exploration rewards (and they exist >0)
		if len(Level.minor_reward_room_counts[step.index][0]) == 0 && num_exploration_rewards > 0:
			#step 0: add rewards to next step
			if step.index == 0:
					Level.route_steps[step.index+1].add_rewards(step_minor_rewards)
					step.clear_minor_rewards()
					continue
			#make all rewards backtracking
			else:
					num_backtracking_rewards += num_exploration_rewards
					num_exploration_rewards = 0
		#distribute exploration rewards
		for i:int in range(num_exploration_rewards):
			existing_room_reward_count = -1 #initialized to 0 in first loop
			selected_room = null
			selected_mu = null
			no_rooms_available = false
			current_reward = step_minor_rewards[i]
			
			while selected_room == null:
				existing_room_reward_count += 1
				#available rooms have too many rewards: force backtracking instead of exploration
				if (existing_room_reward_count >= len(Level.minor_reward_room_counts[step.index]) || existing_room_reward_count >= 3) && step.index > 0:
					num_backtracking_rewards += (num_exploration_rewards - i)
					num_exploration_rewards = i
					no_rooms_available = true
					break
				#obtain room candidates
				potential_room = Level.minor_reward_room_counts[step.index][existing_room_reward_count]
				#single room left
				if potential_room is Room:
					selected_room = potential_room
				#select random room candidate
				elif len(potential_room) > 0:
					random_index = Utils.rng.randf_range(0, len(potential_room)-1)
					potential_room = potential_room.pop_at(random_index)
					selected_room = potential_room
			if no_rooms_available: break
			selected_mu = selected_room.get_random_viable_reward_MU()
			selected_mu.add_reward(current_reward)
			#register new room existing reward count
			if len(Level.minor_reward_room_counts[step.index]) <= existing_room_reward_count+1:
				#initialize array if it's a new tier
				Level.minor_reward_room_counts[step.index].push_back([])
			Level.minor_reward_room_counts[step.index][existing_room_reward_count+1].push_back(selected_room)
		#distribute backtracking rewards
		for i:int in range(num_backtracking_rewards):
			current_reward = step_minor_rewards[num_exploration_rewards+i]
			new_room = null
			new_room_gate = null
			selected_room = null
			selected_mu = null
			new_room_mu_pos = null
			potential_room = step.get_previous_step_rooms() #TODO: edge case no room can be extruded (extremely unlikely)
			#select room to extrude
			while new_room_mu_pos == null:
				selected_room = potential_room[Utils.rng.randi_range(0, len(potential_room)-1)]
				new_room_mu_pos = selected_room.get_adjacent_free_MU_pos()
			#create and connect new room with previous step key
			new_room = Room.createNew(new_room_mu_pos, selected_room.area_index, step.index, Vector2i(1,1))
			new_room_gate = LockedDoor.createNew(Utils.gate_state.TRAVERSABLE, Utils.gate_directionality.TWO_WAY, null, Level.route_steps[step.index-1].keyset)
			common.connect_adjacent_rooms(selected_room, new_room, new_room_gate)
			selected_mu = Level.map.get_mu_at(new_room_mu_pos)
			selected_mu.add_reward(current_reward)
