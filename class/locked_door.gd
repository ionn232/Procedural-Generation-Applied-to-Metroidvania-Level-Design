class_name LockedDoor
extends Resource

var keyset : Array[Key] = []
var state : Utils.gate_state = Utils.gate_state.LOCKED

# Always two positions.
# [0]: player obtains associated key, [1]: player crosses it for the first time
# if null, no transformation occurs
var transformation_table: Array[Utils.gate_state] = []

func define()  -> void:
	transformation_table.resize(2)
	transformation_table.fill(null)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
