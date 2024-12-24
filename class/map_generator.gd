class_name MapGenerator
extends Node2D

@export var map_size_x:int = 10
@export var map_size_y:int = 10

var rooms:Array[Array] = []

func main_process() -> void:
	initialize_room_data()
	var starting_room_coords:Vector2 = Vector2(randi_range(0, map_size_x - 1), randi_range(0, map_size_y - 1))
	
	var example_room = Room.new()
	example_room.define(Utils.border_type.EMPTY, 
		Utils.border_type.EMPTY,
		Utils.border_type.EMPTY,
		Utils.border_type.WALL,
		'powerup whatever idk')
	var ex_json = JSON.stringify(example_room.borders)
	
	rooms[starting_room_coords.x][starting_room_coords.y] = ex_json
	
	adjacent_room_weights()

#returns a set of weights 
func adjacent_room_weights():
	pass
	
func initialize_room_data():
	rooms.resize(map_size_x)
	for i in rooms.size():
		var room_column:Array[String] = []
		room_column.resize(map_size_y)
		room_column.fill("")
		rooms[i] = room_column

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_process()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
