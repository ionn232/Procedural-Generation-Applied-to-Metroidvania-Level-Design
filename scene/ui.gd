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

func _on_advance_btn_button_down() -> void:
	Utils.generator_stage += 1
	step_counter.text = str(Utils.generator_stage)
	stage_changed.emit()
