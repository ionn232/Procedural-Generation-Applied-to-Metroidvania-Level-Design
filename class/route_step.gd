class_name RouteStep
extends Resource

var index:int
var areas:Array[AreaPoint]
var keyset:Array[Key]
var reward_pool:Array #TODO define type n shi

static func createNew(new_index:int = -1,new_areas:Array[AreaPoint] = [], new_keyset:Array[Key] = [], new_RP:Array = []) -> RouteStep:
	var new_RS:RouteStep = RouteStep.new()
	new_RS.index = new_index
	new_RS.areas = new_areas
	new_RS.keyset = new_keyset
	new_RS.reward_pool = new_RP
	return new_RS

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
