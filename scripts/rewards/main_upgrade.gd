class_name MainUpgrade
extends Reward


static func createNew(name:String, desc:String) -> MainUpgrade:
	var newRwrd = MainUpgrade.new()
	newRwrd.name = name
	newRwrd.description = desc
	return newRwrd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
