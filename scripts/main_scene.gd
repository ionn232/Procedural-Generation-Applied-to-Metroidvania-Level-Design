extends Node2D

@onready var room_selection: Label = $UI/UI/RoomSelection
@onready var layout_display: Node2D = $LayoutDisplay

var selected_room_pos = null

func _process(delta: float) -> void:
	#detection
	var mouse_room_coords:Vector2i = layout_display.tilemap_content.local_to_map(get_local_mouse_position() + Vector2(4, 4))
	if (Input.is_action_pressed("Click")):
		if(Level.map.get_mu_at(mouse_room_coords) != null):
			selected_room_pos = mouse_room_coords
		else:
			selected_room_pos = null
	
	#UI
	#TODO: info on room and borders
	#room_selection.text = str(mouse_room_coords)
	if !selected_room_pos:
		room_selection.text = 'no room selected'
	else:
		room_selection.text = str(selected_room_pos)
		var mu:MU = Level.map.get_mu_at(selected_room_pos)
		
		match mu:
			_ when mu.is_fast_travel:
				room_selection.text += '\nWarp point'
			_ when mu.is_save:
				room_selection.text += '\nSave point'
			_ when mu.is_shop:
				room_selection.text += '\nShop'
			_ when mu.is_spawn:
				room_selection.text += '\nSpawn point'
		
		for unlock:Reward in mu.rewards:
			room_selection.text += '\n' + unlock.name
		
		room_selection.text += '\nborder data:'
		
		for i:int in range(4):
			var border = mu.borders[i]
			room_selection.text += '\nborder ' + str(i) + ':  '
			match(border):
				Utils.border_type.EMPTY:
					room_selection.text += 'Empty'
				Utils.border_type.SAME_ROOM:
					room_selection.text += 'Same room'
				Utils.border_type.WALL:
					room_selection.text += 'Wall'
				Utils.border_type.DEATH_ZONE:
					room_selection.text += 'Death zone'
				Utils.border_type.LOCKED_DOOR:
					room_selection.text += 'Gate'
