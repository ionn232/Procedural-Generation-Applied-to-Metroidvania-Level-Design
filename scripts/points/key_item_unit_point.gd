class_name KeyItemUnitPoint
extends Point

const KIU_POINT = preload("res://scene/points/kiu_point.tscn")

#associated key item
var key_value:KeyItem
#key item's unit list index
var key_index:int

var key_unit_value:KeyItemUnit

#associated RS
var associated_RS:RouteStep


static func createNew(pos:Vector2, generic_identity:Point = null) -> KeyItemUnitPoint:
	var newPoint = KIU_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	#newPoint.relations = generic_identity.relations ##use absorb_relations instead
	newPoint.is_generic = false
	
	return newPoint

func set_data(key_item:KeyItem, kiu_value:KeyItemUnit , rs:RouteStep):
	key_value = key_item
	key_unit_value = kiu_value
	key_index = kiu_value.unit_index
	associated_RS = rs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
