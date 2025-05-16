class_name KeyItemUnit
extends Reward

var key:KeyItem
var unit_index:int

static func createNew(name:String, desc:String) -> KeyItemUnit:
	var newRwrd = KeyItemUnit.new()
	newRwrd.name = name
	newRwrd.description = desc
	return newRwrd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
