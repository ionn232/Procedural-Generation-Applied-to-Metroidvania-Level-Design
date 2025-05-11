class_name ConnectionPoint
extends Point

const CONNECTION_POINT = preload("res://scene/points/connection_point.tscn")

var area_relations:Array[ConnectionPoint]
var area_relation_is_progress : Array[bool] #if not, it's backtracking route

static func createNew(pos:Vector2, relations:Array = []) -> ConnectionPoint:
	var newPoint = CONNECTION_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	newPoint.relations = relations
	return newPoint

func add_connector_realtion(other_area_connector:ConnectionPoint, is_progress:bool):
	area_relations.push_back(other_area_connector)
	area_relation_is_progress.push_back(is_progress)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	for area_relation:ConnectionPoint in area_relations:
		var rel_color:Color = Color.WHITE
		draw_line(Vector2(0,0), to_local(area_relation.global_position), rel_color, 1, true)
