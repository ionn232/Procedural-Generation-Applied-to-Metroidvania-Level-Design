class_name KeyItem
extends Reward

var kius:Array[KeyItemUnit]

static func createNew(name:String, desc:String) -> KeyItem:
	var newRwrd = KeyItem.new()
	newRwrd.name = name
	newRwrd.description = desc
	return newRwrd

func assign_units(unit_array:Array[KeyItemUnit]):
	kius.resize(len(unit_array))
	for i:int in range(len(unit_array)):
		var kiu:KeyItemUnit = unit_array[i]
		kiu.unit_index = i
		kiu.key = self
		kius[i] = kiu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
