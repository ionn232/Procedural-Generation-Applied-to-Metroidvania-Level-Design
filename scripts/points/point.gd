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

#move point to an available, free position
func random_reposition(force_first_roll:bool = false):
	var map_boundary_x:float = Level.map_size_x*16/2.0 - 4.0 
	var map_boundary_y:float = Level.map_size_y*16/2.0 - 4.0
	var count:int = -1
	
	if force_first_roll: self.update_position(self.pos + Vector2(Utils.rng.randfn(0.0, Utils.ROOM_SIZE), Utils.rng.randfn(0.0, Utils.ROOM_SIZE)))
	
	while count < 1000:
		count += 1
		#check room superposition
		if Level.map.get_mu_at(Utils.world_pos_to_room(self.global_position)) == null:
			#viable position found
			return
		#roll new position
		self.update_position(self.pos + Vector2(Utils.rng.randfn(0.0, Utils.ROOM_SIZE), Utils.rng.randfn(0.0, Utils.ROOM_SIZE)))
		#keep point inside grid (border mirroring)
		if abs(self.global_position.x) > map_boundary_x:
			var point_to_reflection:Vector2 = Vector2(1, 0) * (2 * (sign(self.global_position.x) * map_boundary_x - self.global_position.x))
			self.update_position(self.pos + point_to_reflection)
		elif abs(self.global_position.y) > map_boundary_y:
			var point_to_reflection:Vector2 = Vector2(0, 1) * (2 * (sign(self.global_position.y) * map_boundary_y - self.global_position.y))
			self.update_position(self.pos + point_to_reflection)

	print('TIMEOUT: POINT REPOSITION at step ', self.associated_step.index)

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
