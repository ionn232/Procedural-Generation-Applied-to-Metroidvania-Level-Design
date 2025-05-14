class_name RouteStep
extends Resource

var index:int
var areas:Array[AreaPoint]
var keyset:Array[Reward] #Array[MainUpgrade || KeyItem] #TODO: this being an array makes no sense with the current implementation, always has one member
var reward_pool:Array[Reward] #Array[SideUpgrade || Equipment || Collectible || StatUpgrade]

static func createNew(new_index:int = -1,new_areas:Array[AreaPoint] = [], new_keyset:Array[Reward] = [], new_RP:Array[Reward] = []) -> RouteStep:
	var new_RS:RouteStep = RouteStep.new()
	new_RS.index = new_index
	new_RS.areas = new_areas
	new_RS.keyset = new_keyset
	new_RS.reward_pool = new_RP
	return new_RS

func get_side_upgrades() -> Array: #return type: Array[SideUpgrade]
	return reward_pool.filter(func(val): return val is SideUpgrade)


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

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
