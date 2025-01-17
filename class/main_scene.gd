extends Node2D

@onready var room_selection: Label = $RoomSelection

var initial_room:Vector2i = Vector2i(0, 0)
var selected_room:Vector2i = Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	room_selection.text = 'Initial Room: ' + str(Map.initial_room.grid_pos) + '\nSelected Room: (0, 0)'
