class_name MapGenerator
extends Node2D

@onready var ui: CanvasLayer = $"../UI" #TODO: delete: load in children
@onready var main_scene: Node2D = $".." #TODO delete: load in children

#load children
@onready var step_1: Node2D = $Step1
@onready var step_2: Node2D = $Step2
@onready var step_3: Node2D = $Step3
@onready var step_4: Node2D = $Step4
@onready var step_5: Node2D = $Step5
@onready var step_6: Node2D = $Step6
@onready var step_7: Node2D = $Step7
@onready var step_8: Node2D = $Step8
@onready var step_9: Node2D = $Step9
@onready var step_10: Node2D = $Step10
@onready var step_11: Node2D = $Step11
@onready var step_12: Node2D = $Step12
@onready var step_13: Node2D = $Step13
@onready var step_14: Node2D = $Step14
@onready var step_15: Node2D = $Step15
@onready var step_16: Node2D = $Step16
@onready var step_17: Node2D = $Step17
@onready var step_18: Node2D = $Step18
@onready var step_19: Node2D = $Step19
@onready var step_20: Node2D = $Step20

#area size DIAMETER
var area_size:float
var area_size_rooms:int
var area_size_xy:Vector2
var area_size_rooms_xy:Vector2i

var draw_angles:bool = false

func _ready() -> void: ##level, map initializations // rng seeding
	ui.stage_changed.connect(_stage_handler.bind())
	ui.result_signal.connect(show_result.bind())
	
	if Utils.config_fixed_rng:
		Utils.rng.seed = hash(Utils.rng_seed_unhashed)
	else:
		Utils.rng.seed = hash(Time.get_unix_time_from_system())
	
	#initialize map
	var main_map:Map = Map.new()
	main_map.initialize_map()
	Level.map = main_map
	
	#area size (DIAMETER)
	area_size = ((Level.map_size_x+Level.map_size_y)*16/2.0)*Level.area_size_multiplier/float(Level.num_areas) #arbitrarily decided
	var w_h_ratio:float = Level.map_size_x/float(Level.map_size_y)
	area_size_xy = Vector2(Level.map_size_x*16*Level.area_size_multiplier/float(Level.num_areas), Level.map_size_y*16*Level.area_size_multiplier/float(Level.num_areas))
	area_size_rooms = ceil(area_size / 16.0)
	area_size_rooms_xy = ceil(area_size_xy / 16.0)
	Level.area_size_xy = area_size_xy
	
	#load reward pool
	RewardPool.import_reward_pool()
	RewardPool.make_equipment(Level.num_equipment)
	RewardPool.make_collectibles(Level.num_collectibles)
	RewardPool.make_stat_ups(Level.num_stat_ups)
	#initialize route step array
	var route_steps:Array[RouteStep]
	route_steps.resize(Level.num_route_steps)
	for i:int in range(Level.num_route_steps):
		route_steps[i] = RouteStep.createNew(i)
	#store info
	Level.route_steps = route_steps
	
	distribute_step_rewards()

func distribute_step_rewards():
	var route_steps:Array[RouteStep] = Level.route_steps
	var keyset_indexes:Array = range(len(RewardPool.keyset))
	var side_indexes:Array = range(len(RewardPool.side_upgrades))
	var RS_item_weight:float
	var side_upgrades_left:int = Level.num_side_upgrades
	var equipment_items_left:int = Level.num_equipment
	var collectibles_left:int = Level.num_collectibles
	var stat_upgrades_left:int = Level.num_stat_ups
	var roll:float
	for i:int in range(Level.num_route_steps):
		#assign RS main key
		var indexes_random_index:int = Utils.rng.randi_range(0, len(keyset_indexes)-1)
		route_steps[i].add_key(RewardPool.keyset[keyset_indexes.pop_at(indexes_random_index)])
		#assign side upgrades
		RS_item_weight = side_upgrades_left / float(Level.num_route_steps - i)
		while RS_item_weight > 1.0:
			indexes_random_index = Utils.rng.randi_range(0, len(side_indexes)-1)
			route_steps[i].add_reward(RewardPool.side_upgrades[side_indexes.pop_at(indexes_random_index)])
			side_upgrades_left -= 1
			RS_item_weight -= 1.0
		roll = Utils.rng.randf()
		if roll < RS_item_weight:
			indexes_random_index = Utils.rng.randi_range(0, side_upgrades_left - 1)
			route_steps[i].add_reward(RewardPool.side_upgrades[side_indexes.pop_at(indexes_random_index)])
			side_upgrades_left -= 1
		#assign equipment
		RS_item_weight = equipment_items_left / float(Level.num_route_steps - i)
		while RS_item_weight > 1.0:
			route_steps[i].add_reward(RewardPool.equipment[Level.num_equipment - equipment_items_left])
			equipment_items_left -= 1
			RS_item_weight -= 1.0
		roll = Utils.rng.randf()
		if roll < RS_item_weight:
			route_steps[i].add_reward(RewardPool.equipment[Level.num_equipment - equipment_items_left])
			equipment_items_left -= 1
		#assign collectibles
		RS_item_weight = collectibles_left / float(Level.num_route_steps - i)
		while RS_item_weight > 1.0:
			route_steps[i].add_reward(RewardPool.collectibles[Level.num_collectibles - collectibles_left])
			collectibles_left -= 1
			RS_item_weight -= 1.0
		roll = Utils.rng.randf()
		if roll < RS_item_weight:
			route_steps[i].add_reward(RewardPool.collectibles[Level.num_collectibles - collectibles_left])
			collectibles_left -= 1
		#assign stat upgrades
		RS_item_weight = stat_upgrades_left / float(Level.num_route_steps - i)
		while RS_item_weight > 1.0:
			route_steps[i].add_reward(RewardPool.stat_upgrades[Level.num_stat_ups - stat_upgrades_left])
			stat_upgrades_left -= 1
			RS_item_weight -= 1.0
		roll = Utils.rng.randf()
		if roll < RS_item_weight:
			route_steps[i].add_reward(RewardPool.stat_upgrades[Level.num_stat_ups - stat_upgrades_left])
			stat_upgrades_left -= 1

func _stage_handler():
	var time_start = Time.get_unix_time_from_system()
	match(Utils.generator_stage):
		1:
			step_1.execute()
		2:
			step_2.execute()
		3:
			step_3.execute()
		4:
			step_4.execute()
		5:
			step_5.execute()
		6:
			step_6.execute()
		7:
			step_7.execute()
		8:
			step_8.execute()
		9:
			step_9.execute()
		10:
			step_10.execute()
		11:
			step_11.execute()
		12:
			step_12.execute()
		13:
			step_13.execute()
		14:
			step_14.execute()
		15:
			step_15.execute()
		16:
			step_16.execute()
		17:
			step_17.execute()
		18:
			step_18.execute()
		19:
			step_19.execute()
		20:
			step_20.execute()
	print('time for step ', str(Utils.generator_stage), ': ', float(Time.get_unix_time_from_system() - time_start))
	Utils.redraw_all()

func show_result():
	var time_start = Time.get_unix_time_from_system()
	step_1.execute()
	step_2.execute()
	step_3.execute()
	step_4.execute()
	step_5.execute()
	step_6.execute()
	step_7.execute()
	step_8.execute()
	step_9.execute()
	step_10.execute()
	step_11.execute()
	step_12.execute()
	step_13.execute()
	step_14.execute()
	step_15.execute()
	step_16.execute()
	step_17.execute()
	step_18.execute()
	step_19.execute()
	step_20.execute()
	print('time for complete process: ', float(Time.get_unix_time_from_system() - time_start))
	Utils.redraw_all()
