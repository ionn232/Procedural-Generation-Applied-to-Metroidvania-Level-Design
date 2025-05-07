extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = Vector2(0,0) + get_global_mouse_position()*0.5
	
	if Input.is_action_just_pressed("ZoomTick"):
		self.zoom *= 2
	elif Input.is_action_just_pressed("UnZoomTick"):
		self.zoom /= 2
