class_name Base_Ai
extends Node

@export var character: CharacterBase
@export var detecion_area:Area2D
@export var block_detection: Area2D
@export var no_block_detection: Area2D
@export var Attack_source: AttackComponent

@export var detect_range:bool = true

@export var detect_block:bool = true

@export var detect_no_block:bool = true



@export var direction: float 

@export var is_normal_movement:bool = true
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	if character.get_node("Shoot_point").has_node("Detection_range"):

		detecion_area.connect("body_entered",spawn_attack)
	if character.get_node("Shoot_point").has_node("Detect_block"):
		block_detection.connect("body_entered",turn_around)
	if character.get_node("Shoot_point").has_node("Detect_no_block"):
		no_block_detection.connect("body_exited",turn_around)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func turn_around(_throw):

	direction  = -direction

func spawn_attack(the_attacked):

	if the_attacked.has_node("PlayerComponent")	:
		Attack_source.fire()
func _process(_delta):
	character.direction = direction
	if is_normal_movement:

		character.animation()
		character.movement(_delta)
