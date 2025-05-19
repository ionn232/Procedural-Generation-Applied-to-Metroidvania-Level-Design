extends CanvasLayer

@onready var step_counter: Label = $UI/StepCounter
@onready var route_step_info: Label = $UI/RouteStepInfo

signal stage_changed()
@onready var advance_btn: Button = $AdvanceBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_rs_info():
	route_step_info.text = ''
	for RS:RouteStep in Level.route_steps:
		route_step_info.text += '\n---------------------------------------------------------------\n'
		route_step_info.text += 'RS' + str(RS.index) + ' with areas: '
		for area in RS.areas:
			route_step_info.text += str(area.area_index)

const STEP_DESCRIPTIONS = [
	'',
	'Place area points',
	'Expand area points',
	'Establish initial area',
	'Establish area connections',
	'Designate area order',
	'Establish hub-containing area if applicable',
	'Distribute route steps',
	'Place essential points',
	'Place additional points for route step rewards',
	'Expand area subpoints',
	'Assign inter-area connection points',
	'Establish area subpoint connections',
	'Assign fast travel points',
	'Assign spawn point in initial area',
	'Assign side upgrade, main upgrade and key item unit points',
	'Place rooms for all points',
	'Prepare hub zone',
	'Establish point connections',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
	'',
]

func display_step_desc(current_stage:int):
	step_counter.text = STEP_DESCRIPTIONS[current_stage]
	step_counter.text += '\n' + str(Utils.generator_stage)


func _on_advance_btn_button_down() -> void:
	Utils.generator_stage += 1
	display_step_desc(Utils.generator_stage)
	stage_changed.emit()
