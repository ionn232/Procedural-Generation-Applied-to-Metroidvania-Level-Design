class_name RouteStep
extends Resource

var index:int
var areas:Array[AreaPoint]
var keyset:Array[Reward] #Array[MainUpgrade || KeyItem] #note: always one member in current implementation
var reward_pool:Array[Reward] #Array[SideUpgrade || Equipment || Collectible || StatUpgrade] #TODO: separate side upgrades and minor rewards for efficiency

var has_new_area:bool = false
var num_exploration_rewards:int = 0
var num_backtracking_rewards:int = 0

static func createNew(new_index:int = -1,new_areas:Array[AreaPoint] = [], new_keyset:Array[Reward] = [], new_RP:Array[Reward] = []) -> RouteStep:
	var new_RS:RouteStep = RouteStep.new()
	new_RS.index = new_index
	new_RS.areas = new_areas
	new_RS.keyset = new_keyset
	new_RS.reward_pool = new_RP
	return new_RS

func get_side_upgrades() -> Array: #return type: Array[SideUpgrade]
	return reward_pool.filter(func(val): return val is SideUpgrade)

func get_minor_rewards() -> Array: #return type: Array[Equipment || StatUpgrade || Collectible]
	return reward_pool.filter(func(val): return !(val is SideUpgrade))

func get_previous_step_rooms() -> Array[Room]:
	var previous_step_rooms = Level.rooms.filter(func(val:Room): return val.step_index < self.index)
	return previous_step_rooms

func add_key(new_key:Reward):
	keyset.push_back(new_key)
	new_key.route_step = self
	if new_key is KeyItem:
		for i:int in range(len(new_key.kius)):
			var kiu:KeyItemUnit = new_key.kius[i]
			kiu.unit_index = i
			kiu.route_step = self

func add_reward(new_reward:Reward):
	reward_pool.push_back(new_reward)
	new_reward.route_step = self

func add_rewards(new_rewards:Array[Reward]):
	for new_reward:Reward in new_rewards:
		reward_pool.push_back(new_reward)
		new_reward.route_step = self

func clear_minor_rewards():
	reward_pool = reward_pool.filter(func(val): return (val is SideUpgrade))

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
