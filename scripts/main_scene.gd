extends Node2D

@onready var layout_display: Node2D = $LayoutDisplay
@onready var room_selection: Label = $UI/UI/RoomSelection
@onready var route_steps_keyset: Label = $UI/UI/RouteStepsKeyset
@onready var ui: Control = $UI/UI

static var selected_room_pos = null

signal room_selected()

func _process(delta: float) -> void:
	#input detection
	var mouse_room_coords:Vector2i = layout_display.tilemap_content.local_to_map(get_local_mouse_position() + Vector2(4, 4))
	if (Input.is_action_just_pressed("Click")):
		if Utils.is_pos_inside_map(mouse_room_coords) && (Level.map.get_mu_at(mouse_room_coords) != null):
			selected_room_pos = mouse_room_coords
			room_selected.emit()
		else:
			selected_room_pos = null
	if (Input.is_action_just_pressed("UIToggle")):
		ui.visible = !ui.visible
	
