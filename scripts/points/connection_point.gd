class_name ConnectionPoint
extends Point

const CONNECTION_POINT = preload("res://scene/points/connection_point.tscn")

var area_relations:Array[ConnectionPoint]
var area_relation_is_progress : Array[bool] #if not, it's backtracking route
var area_relation_is_mapped : Array[bool]

static func createNew(pos:Vector2, generic_identity:Point = null) -> ConnectionPoint:
	var newPoint = CONNECTION_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	newPoint.relations = []
	newPoint.is_generic = false
	return newPoint

func add_connector_relation(other_area_connector:ConnectionPoint, is_progress:bool):
	if !(area_relations.has(other_area_connector)):
		area_relations.push_back(other_area_connector)
		area_relation_is_progress.push_back(is_progress)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	#draw point relation lines
	if Utils.debug_show_relations:
		for i:int in range(len(relations)):
			var connecting_point:Point = relations[i]
			draw_line(Vector2(0,0), to_local(connecting_point.global_position), Color.WHITE, 1, true)
		#draw connection relation lines
		for i:int in range(len(area_relations)):
			var connecting_relation_point:ConnectionPoint = area_relations[i]
			var rel_color:Color = Color.WHITE if area_relation_is_progress[i] else Color.WEB_GRAY
			draw_line(Vector2(0,0), to_local(connecting_relation_point.global_position), rel_color, 1, true)
