class_name MainUpgradePoint
extends Point

const MAIN_UPGRADE_POINT = preload("res://scene/points/main_upgrade_point.tscn")

#assiociated key
var key_value:MainUpgrade

#associated RS
var associated_RS:RouteStep

static func createNew(pos:Vector2, generic_identity:Point = null) -> MainUpgradePoint:
	var newPoint = MAIN_UPGRADE_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	#newPoint.relations = generic_identity.relations ##use absorb_relations instead
	newPoint.is_generic = false
	
	return newPoint

func set_data(key:MainUpgrade, rs:RouteStep):
	key_value = key
	associated_RS = rs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
