class_name Base_Ai
extends Node

@export var character: CharacterBase
@export var attacking_range:Area2D
@export var block_detection: Area2D
@export var no_block_detection: Area2D
@export var Attack_source: AttackComponent





@export var direction: float 

@export var is_normal_movement:bool = true
# Called when the node enters the scene tree for the first time.
func _ready():
	
	await get_tree().create_timer(0.1).timeout
	if attacking_range != null:
		attacking_range.connect("body_entered",spawn_attack)
	if block_detection != null:
		block_detection.connect("body_entered",turn_around)
	if no_block_detection != null:
		no_block_detection.connect("body_exited",turn_around)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func turn_around(_throw):
	if block_detection != null:
		block_detection.disconnect("body_entered",turn_around)
	if no_block_detection != null:
		no_block_detection.disconnect("body_exited",turn_around)
	print("around")
	direction  = -direction
	await get_tree().create_timer(0.1).timeout

	if block_detection != null:
		block_detection.connect("body_entered",turn_around)
	if no_block_detection != null:
		no_block_detection.connect("body_exited",turn_around)

func spawn_attack(the_attacked):
	if the_attacked.has_node("PlayerComponent")	:
		Attack_source.fire()
func _process(_delta):
	character.direction = direction
	if is_normal_movement:

		character.animation()
		character.movement(_delta)
