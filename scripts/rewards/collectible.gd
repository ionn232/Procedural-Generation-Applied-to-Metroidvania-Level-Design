class_name Collectible
extends Reward


static func createNew(name:String, desc:String) -> Collectible:
	var newRwrd = Collectible.new()
	newRwrd.name = name
	newRwrd.description = desc
	return newRwrd

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass
