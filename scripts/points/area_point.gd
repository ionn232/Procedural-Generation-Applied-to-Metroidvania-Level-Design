class_name AreaPoint
extends Point
#Each area point represents one area of the game.
#They dictate area connections on an abstract level

#prefab for instancing
const AREA_POINT = preload("res://scene/points/area_point.tscn")

var area_index : int
var has_hub : bool = false

var intra_area_distance:Vector2 = Vector2(0,0)

#parity in size to base class 'relations': each 'i' refers to the same area
var relation_is_progress : Array[bool] #if not, it's backtracking route

var subpoints:Array #type: Array[Point] or subclasses
var reward_pool:Array #type: Array[Reward] or subclasses

static func createNew(pos:Vector2, generic_identity:Point = null) -> AreaPoint:
	var newPoint = AREA_POINT.instantiate()
	newPoint.visible = Utils.debug_show_points
	newPoint.position = pos
	newPoint.pos = pos
	newPoint.relations = []
	newPoint.is_generic = false
	return newPoint

func calculate_intra_area_distance():
	var x_value:float = Level.map_size_x*16*Level.area_size_multiplier / float(Level.num_areas) / float(len(subpoints))
	var y_value:float = Level.map_size_y*16*Level.area_size_multiplier / float(Level.num_areas) /float(len(subpoints))
	intra_area_distance = Vector2(max(x_value, Utils.ROOM_SIZE + 1), max(y_value, Utils.ROOM_SIZE + 1))
	if intra_area_distance == Vector2(Utils.ROOM_SIZE + 1, Utils.ROOM_SIZE + 1):
		print('WARNING: area size too low, please adjust multiplier')

func add_subarea_nodes():
	for subpoint:Point in subpoints:
		if !(subpoint.get_parent() == self):
			add_child(subpoint, true)
			subpoint.set_point_color(Utils.area_colors[area_index])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw(): #USES LOCAL COORDINATES!
	#draw area size
	if Utils.debug_show_area_size:
		var area_rect:Rect2 = Rect2(-Vector2(Level.area_size_xy.x/2.0, Level.area_size_xy.y/2.0), Vector2(Level.area_size_xy.x, Level.area_size_xy.y))
		draw_rect(area_rect, Color.BLACK, false)
	#draw area relation angles
	if Utils.debug_show_point_angles:
		for related_area:AreaPoint in relations:
			var angle = global_position.angle_to_point(related_area.global_position)
			var direction = Vector2(1,0)
			var angle_1 = direction.rotated(angle + Utils.MIN_ANGULAR_DISTANCE)
			var angle_2 = direction.rotated(angle - Utils.MIN_ANGULAR_DISTANCE)
			draw_line(Vector2(0,0), angle_1 * 100, Color(1,1,1,0.3) * Utils.area_colors[related_area.area_index], 2, false)
			draw_line(Vector2(0,0), angle_2 * 100, Color(1,1,1,0.3) * Utils.area_colors[related_area.area_index], 2, false)
	#draw area relation lines
	if Utils.debug_show_relations:
		for i:int in range(len(relations)):
			var connecting_area:AreaPoint = relations[i]
			if Utils.generator_stage < 4:
				draw_line(Vector2(0,0), to_local(connecting_area.pos), Color.WHITE, 1, true)
			elif (Utils.generator_stage >= 4 && Utils.generator_stage < 10):
				var rel_color:Color = Color.WHITE if relation_is_progress[i] else Color.WEB_GRAY
				draw_line(Vector2(0,0), to_local(connecting_area.pos), rel_color, 1, true)
	#draw area index
	if Utils.debug_show_point_indexes:
		if (Utils.generator_stage >= 4):
			draw_string(font,Vector2(0,20), str(area_index), 0, -1, 32, Color.BLACK)
	
	#remark hub-containing area
	if self.has_hub:
		draw_circle(Vector2(0,0), 10, Utils.area_colors[area_index] * Color(1,1,1,sprite.modulate.a*0.5), false, 2.0, true)
	
	#subpoints:
	for i:int in range(len(subpoints)):
		var subpoint:Point = subpoints[i]
		#draw intra area distance
		if Utils.debug_show_intra_area_size:
			draw_rect(Rect2(subpoint.pos - Vector2(intra_area_distance.x/2.0, intra_area_distance.y/2.0), Vector2(intra_area_distance.x,intra_area_distance.y)), Color.BLACK, false)
			if subpoint is FastTravelPoint and has_hub:
				draw_rect(Rect2(subpoint.pos - Vector2(intra_area_distance.x, intra_area_distance.y), Vector2(intra_area_distance.x*2,intra_area_distance.y*2)), Color.BLACK, false)
		#draw subpoint index
		if Utils.debug_show_point_indexes:
			draw_string(font , subpoint.pos + Vector2(0,20), str(i), 0, -1, 16, Color.BLACK)
		#draw step index
		if subpoint.associated_step != null && Utils.debug_show_point_steps:
			draw_string(font , subpoint.pos + Vector2(0, -20), str(subpoint.associated_step.index), 0, -1, 16, Color.WHITE)
		#draw subpoint relation angles
		if Utils.debug_show_point_angles:
			for related_point:Point in subpoint.relations:
				var angle = subpoint.global_position.angle_to_point(related_point.global_position)
				var direction = Vector2(1,0)
				var angle_1 = direction.rotated(angle + Utils.MIN_ANGULAR_DISTANCE)
				var angle_2 = direction.rotated(angle - Utils.MIN_ANGULAR_DISTANCE)
				draw_line(subpoint.pos, subpoint.pos + angle_1 * 50, Color(0,0,0,0.8), 1, false)
				draw_line(subpoint.pos, subpoint.pos + angle_2 * 50, Color(0,0,0,0.8), 1, false)
