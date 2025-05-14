class_name Reward
extends Resource

var name : String
var description : String
var route_step : RouteStep

static func createNew(name:String, desc:String) -> Reward:
	var newRwrd = Reward.new()
	newRwrd.name = name
	newRwrd.description = desc
	return newRwrd
