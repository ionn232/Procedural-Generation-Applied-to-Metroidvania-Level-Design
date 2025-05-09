class_name AreaPoint
extends Node2D
#Each area point represents one area of the game.
#They dictate area connections on an abstract level

#prefab for instancing
const AREA_POINT = preload("res://scene/area_point.tscn")
const font = preload("res://data/upheavtt.ttf")

@onready var sprite: AnimatedSprite2D = $Sprite

#its a node2D, position is stored in 'position'
var pos : Vector2

var area_index : int

#parity in size, each i refers to the same area
var relations : Array[AreaPoint]
var relation_is_progress : Array[bool] #if not, it's backtracking route

var has_hub : bool = false

static func createNew(pos:Vector2, relations:Array[AreaPoint] = []) -> AreaPoint:
	var newPoint = AREA_POINT.instantiate()
	newPoint.position = pos
	newPoint.pos = pos
	newPoint.relations = relations
	return newPoint

func update_position(newPos:Vector2):
	pos = newPos
	position = newPos

func set_point_color(newColor:Color):
	sprite.self_modulate = newColor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw(): #USES LOCAL COORDINATES!
	#draw area index
	if (Utils.generator_stage == 5):
		draw_string_outline(font, Vector2(0,20), str(area_index),0,-1,32,0.5,Color.BLACK)
	
	#draw area relation lines
	for i:int in range(len(relations)):
		var connecting_area:AreaPoint = relations[i]
		if (Utils.generator_stage == 5):
			var rel_color:Color = Color.WHITE if relation_is_progress[i] else Color.DIM_GRAY
			draw_line(Vector2(0,0), to_local(connecting_area.pos), rel_color, 1, true)
		else:
			draw_line(Vector2(0,0), to_local(connecting_area.pos), Color.WHITE, 1, true)
