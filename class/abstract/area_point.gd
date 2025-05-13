class_name AreaPoint
extends Point
#Each area point represents one area of the game.
#They dictate area connections on an abstract level

#prefab for instancing
const AREA_POINT = preload("res://scene/points/area_point.tscn")

var area_index : int
var has_hub : bool = false

#parity in size to base class 'relations': each 'i' refers to the same area
var relation_is_progress : Array[bool] #if not, it's backtracking route

var subpoints:Array #type: Array[Point] or subclasses
var upgrade_pool:Array #type: Array[Reward] or subclasses

static func createNew(pos:Vector2, generic_identity:Point = null) -> AreaPoint:
	var newPoint = AREA_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	newPoint.relations = []
	newPoint.is_generic = false
	return newPoint

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
	#draw area relation lines
	for i:int in range(len(relations)):
		var connecting_area:AreaPoint = relations[i]
		if Utils.generator_stage < 5: ##TODO 5 <--> 6 i was debugging
			draw_line(Vector2(0,0), to_local(connecting_area.pos), Color.WHITE, 1, true)
		elif (Utils.generator_stage >= 5 && Utils.generator_stage < 10):
			var rel_color:Color = Color.WHITE if relation_is_progress[i] else Color.WEB_GRAY
			draw_line(Vector2(0,0), to_local(connecting_area.pos), rel_color, 1, true)
	
	#draw area index
	if (Utils.generator_stage >= 5):
		draw_string(font,Vector2(0,20), str(area_index), 0, -1, 32, Color.BLACK)
	
	#circle hub-containing area
	if self.has_hub:
		draw_circle(Vector2(0,0), 10, Utils.area_colors[area_index] * Color(1,1,1,sprite.modulate.a), false, 2.0, true)
