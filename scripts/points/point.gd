class_name Point
extends Node2D

#prefab for instancing
const POINT = preload("res://scene/points/point.tscn")
const font = preload("res://data/upheavtt.ttf")

@onready var sprite: AnimatedSprite2D = $Sprite

#its a node2D, position is stored in 'position'. #TODO i think this is redundant
var pos : Vector2

var is_generic:bool = true
var is_protected:bool = false

var relations : Array #type: Array[Point] (or subclass)
var relation_is_mapped : Array[bool] #index parity ^, relation rooms built? 

var associated_room:Room

var associated_step:RouteStep

static func createNew(pos:Vector2, generic_identity:Point = null) -> Point:
	var newPoint = POINT.instantiate()
	newPoint.relations = []
	newPoint.position = pos
	newPoint.pos = pos
	return newPoint

func update_position(newPos:Vector2):
	pos = newPos
	position = newPos

func set_point_color(newColor:Color):
	#sprite.modulate = newColor
	sprite.self_modulate = newColor

func absorb_relations(original_point:Point):
	#restore relations from previous generic point to self and relations
	self.relations = original_point.relations
	for existing_relation:Point in original_point.relations:
		var relation_relations:Array = existing_relation.relations
		var index = relation_relations.find(original_point)
		relation_relations[index] = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw():
	#draw point relation lines
	for i:int in range(len(relations)):
		if Utils.debug_show_relations:
			var connecting_point:Point = relations[i]
			draw_line(Vector2(0,0), to_local(connecting_point.global_position), Color.WHITE, 1, true)
