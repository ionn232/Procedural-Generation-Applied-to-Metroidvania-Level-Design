extends CanvasLayer

signal stage_changed()
@onready var advance_btn: Button = $AdvanceBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_advance_btn_button_down() -> void:
	Utils.generator_stage += 1
	stage_changed.emit()
