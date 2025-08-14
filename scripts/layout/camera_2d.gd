extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("rClick"):
		position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("ZoomTick"):
		self.zoom *= 1.25
	elif Input.is_action_just_pressed("UnZoomTick"):
		self.zoom /= 1.25
