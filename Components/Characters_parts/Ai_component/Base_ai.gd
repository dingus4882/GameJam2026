class_name Base_Ai
extends Node

@export var character: CharacterBase
@export var attacking_range:Area2D
@export var block_detection: Area2D
@export var no_block_detection: Area2D
@export var Attack_source: AttackComponent

@export var want_to_touch:bool = false

@export var bullet_overide: Bullet
@export var shoot_point_overide: Marker2D

@export var direction: float 

@export var is_normal_movement:bool = true

var _is_turning: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("_resolve_references")
	await get_tree().create_timer(0.1).timeout
	if attacking_range != null and not want_to_touch:
		attacking_range.connect("body_entered",spawn_attack)
	if block_detection != null:
		block_detection.connect("body_entered",turn_around)
	if no_block_detection != null:
		no_block_detection.connect("body_exited",turn_around)
		
	if Attack_source.currentBullet == null:
		Attack_source.currentBullet = Attack_source.bullets[0]

func _resolve_references() -> void:
	if not is_instance_valid(character):
		character = get_parent() as CharacterBase

	if not is_instance_valid(Attack_source) and is_instance_valid(character):
		Attack_source = character.get_node_or_null("AttackComponent") as AttackComponent





# Called every frame. 'delta' is the elapsed time since the previous frame.
func turn_around(_body):
	if _is_turning:
		return
	_is_turning = true
	direction = -direction
	await get_tree().create_timer(0.2).timeout # Cooldown to prevent rapid turning
	_is_turning = false

@export var fire_rate: float = 0.5

func spawn_attack(the_attacked):
	if character.current_state == character.States.ATTACKING:
		return
	if bullet_overide:
		Attack_source.currentBullet = bullet_overide
	if shoot_point_overide:
		Attack_source.shoot_point = shoot_point_overide
	if the_attacked.has_node("PlayerComponent")	:
		
		Attack_source.fire()
		
func _physics_process(_delta):
	if TimeManager._menu_open_count > 0 or character.force_stop:
		return

	if not is_instance_valid(character):
		_resolve_references()
		if not is_instance_valid(character):
			return

	character.direction = direction
	if is_normal_movement :
		character.animation()
		character.movement(_delta)
