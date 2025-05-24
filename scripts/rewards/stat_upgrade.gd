class_name StatUpgrade
extends Reward


static func createNew(name:String, desc:String) -> StatUpgrade:
	var newRwrd = StatUpgrade.new()
	newRwrd.name = name
	newRwrd.description = desc
	return newRwrd

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
