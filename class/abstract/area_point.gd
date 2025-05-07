class_name AreaPoint
extends Node2D
#Each area point represents one area of the game.
#They dictate area connections on an abstract level

#prefab for instancing
const AREA_POINT = preload("res://scene/area_point.tscn")

@onready var sprite: AnimatedSprite2D = $Sprite

#its a node2D, position is stored in 'position'
var pos : Vector2
var relations : Array[AreaPoint]
var area_index : int

static func createNew(pos:Vector2, relations:Array[AreaPoint] = []) -> AreaPoint:
	var newPoint = AREA_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	newPoint.relations = relations
	return newPoint

func update_position(newPos:Vector2):
	pos = newPos
	position = newPos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
