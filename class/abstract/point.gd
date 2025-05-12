class_name Point
extends Node2D

#prefab for instancing
const POINT = preload("res://scene/points/point.tscn")
const font = preload("res://data/upheavtt.ttf")

@onready var sprite: AnimatedSprite2D = $Sprite

#its a node2D, position is stored in 'position'
var pos : Vector2

var relations : Array #type: Array[Point] (or subclass)

static func createNew(pos:Vector2, relations:Array = []) -> Point:
	var newPoint = POINT.instantiate()
	newPoint.relations = relations
	newPoint.position = pos
	newPoint.pos = pos
	return newPoint

func update_position(newPos:Vector2):
	pos = newPos
	position = newPos

func set_point_color(newColor:Color):
	sprite.modulate = newColor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	#draw point relation lines
	for i:int in range(len(relations)):
		var connecting_point:Point = relations[i]
		draw_line(Vector2(0,0), to_local(connecting_point.global_position), Color.WHITE, 1, true)
