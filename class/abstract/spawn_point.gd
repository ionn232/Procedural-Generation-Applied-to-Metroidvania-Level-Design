class_name SpawnPoint
extends Point

const SPAWN_POINT = preload("res://scene/points/spawn_point.tscn")

static func createNew(pos:Vector2, generic_identity:Point = null) -> SpawnPoint:
	var newPoint = SPAWN_POINT.instantiate()
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
