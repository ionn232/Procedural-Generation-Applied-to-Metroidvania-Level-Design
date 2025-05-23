extends Node2D

@onready var layout_display: Node2D = $LayoutDisplay
@onready var room_selection: Label = $UI/UI/RoomSelection
@onready var route_steps_keyset: Label = $UI/UI/RouteStepsKeyset
@onready var ui: Control = $UI/UI

var selected_room_pos = null

func _process(delta: float) -> void:
	#input detection
	var mouse_room_coords:Vector2i = layout_display.tilemap_content.local_to_map(get_local_mouse_position() + Vector2(4, 4))
	if (Input.is_action_pressed("Click")):
		if Utils.is_pos_inside_map(mouse_room_coords) && (Level.map.get_mu_at(mouse_room_coords) != null):
			selected_room_pos = mouse_room_coords
		else:
			selected_room_pos = null
	if (Input.is_action_just_pressed("UIToggle")):
		ui.visible = !ui.visible
	
	#UI TODO:move to ui script, call on signal new room selected
	route_steps_keyset.text = ''
	for route_step:RouteStep in Level.route_steps:
		route_steps_keyset.text += '\n------------------------------- ' + 'step ' + str(route_step.index)
		route_steps_keyset.text += '\nkeys: '
		for key:Reward in route_step.keyset:
			route_steps_keyset.text += key.name + ', '
		route_steps_keyset.text += '\nupgrades: '
		for upgrade:Reward in route_step.reward_pool:
			route_steps_keyset.text += upgrade.name + ', '
	
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
			room_selection.text += '\n'
			var border = mu.borders[i]
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
					if len(mu.border_data[i].keyset) > 0:
						for key in mu.border_data[i].keyset:
							room_selection.text += str(key.name) + ' // '
					room_selection.text += 'Gate'
