extends Node2D

@onready var room_selection: Label = $UI/UI/RoomSelection
@onready var route_steps_keyset: Label = $UI/UI/RouteStepsKeyset

@onready var ui: Control = $UI/UI
@onready var step_counter: Label = $UI/UI/StepCounter

@onready var map_generator: MapGenerator = $MapGenerator
@onready var layout_display: LayoutDisplay = $LayoutDisplay

const LAYOUT_DISPLAY = preload("res://scene/layout_display.tscn")
const MAP_GENERATOR = preload("res://scene/map_generator.tscn")

static var selected_room_pos = null

signal room_selected()

func _process(delta: float) -> void:
	#input detection
	if (Input.is_action_just_pressed("Click")):
		var mouse_room_coords:Vector2i = layout_display.tilemap_content.local_to_map(get_local_mouse_position() + Vector2(4, 4))
		if Utils.is_pos_inside_map(mouse_room_coords) && (Level.map.get_mu_at(mouse_room_coords) != null):
			selected_room_pos = mouse_room_coords
			room_selected.emit()
		else:
			selected_room_pos = null
	if (Input.is_action_just_pressed("UIToggle")):
		ui.visible = !ui.visible
	
	if Input.is_action_just_pressed("Reset"):
		step_counter.text = '\n0'
		reset()

func reset():
	Utils.generator_stage = 0
	Level.reset()
	step_counter.text = '\n0'
	
	map_generator.free()
	map_generator = MAP_GENERATOR.instantiate()
	add_child(map_generator, true)
	
	layout_display.free()
	layout_display = LAYOUT_DISPLAY.instantiate()
	add_child(layout_display, true)
