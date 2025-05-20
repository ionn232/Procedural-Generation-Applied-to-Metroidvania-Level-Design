class_name SideUpgradePoint
extends Point

const SIDE_UPGRADE_POINT = preload("res://scene/points/side_upgrade_point.tscn")

#assiociated key
var key_value:SideUpgrade

#associated RS
var associated_RS:RouteStep

static func createNew(pos:Vector2, generic_identity:Point = null) -> SideUpgradePoint:
	var newPoint = SIDE_UPGRADE_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	#newPoint.relations = generic_identity.relations
	newPoint.is_generic = false
	
	return newPoint

func set_data(key:SideUpgrade, rs:RouteStep):
	key_value = key
	associated_RS = rs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
