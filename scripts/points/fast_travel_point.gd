class_name FastTravelPoint
extends Point

const FAST_TRAVEL_POINT = preload("res://scene/points/fast_travel_point.tscn")


static func createNew(pos:Vector2, generic_identity:Point = null) -> FastTravelPoint:
	var newPoint = FAST_TRAVEL_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	newPoint.relations = generic_identity.relations
	newPoint.is_generic = false
	
	#restore relations from previous generic point to self and relations
	for existing_relation:Point in generic_identity.relations:
		var relation_relations:Array = existing_relation.relations
		var index = relation_relations.find(generic_identity)
		relation_relations[index] = newPoint
	
	return newPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	#draw point relation lines
	for i:int in range(len(relations)):
		var connecting_point:Point = relations[i]
		draw_line(Vector2(0,0), to_local(connecting_point.global_position), Color.WHITE, 1, true)
