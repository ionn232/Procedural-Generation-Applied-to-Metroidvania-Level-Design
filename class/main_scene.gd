extends Node2D

@onready var room_selection: Label = $UI/Container/RoomSelection
@onready var layout_display: Node2D = $LayoutDisplay

var selected_room_pos = null

func _process(delta: float) -> void:
	#detection
	var mouse_room_coords:Vector2i = layout_display.tilemap.local_to_map(get_local_mouse_position()/2 + Vector2(2,2))
	if (Input.is_action_pressed("Click")):
		if(Utils.is_pos_inside_map(mouse_room_coords) && Level.map.MUs[mouse_room_coords.x][mouse_room_coords.y] != null):
			selected_room_pos = mouse_room_coords
		else:
			selected_room_pos = null
	
	#UI
	if Utils.generator_stage > 20:
		room_selection.text = 'Initial MU: ' + str(Level.initial_room.grid_pos)
		if (selected_room_pos == null):
			room_selection.text += '\nNo MU selected'
		elif (Level.map.MUs[selected_room_pos.x][selected_room_pos.y]):
			room_selection.text += '\nSelected MU: ' + str(selected_room_pos)
			for border:Utils.border_type in Level.map.MUs[selected_room_pos.x][selected_room_pos.y].borders:
				room_selection.text += '\nborder: ' + str(border)
