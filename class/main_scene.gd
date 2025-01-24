extends Node2D

@onready var room_selection: Label = $RoomSelection
@onready var layout_display: Node2D = $LayoutDisplay


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#TODO: hit detection is wonky
	var mouse_room_coords:Vector2i = layout_display.tilemap.local_to_map(get_local_mouse_position() / 2)
	if (Input.is_action_pressed("Click") && Utils.is_pos_inside_map(mouse_room_coords) && Level.complete_map.rooms[mouse_room_coords.x][mouse_room_coords.y] != null):
		Utils.gui_selected_room = mouse_room_coords
	room_selection.text = 'Initial Room: ' + str(Level.initial_room.grid_pos) + '\nSelected Room: ' + str(Utils.gui_selected_room)
