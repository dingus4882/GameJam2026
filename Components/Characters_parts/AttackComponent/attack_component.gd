class_name AttackComponent
extends Node

var is_mutated: bool = false
var currentBullet: Bullet
var can_fire = true

@export var bullets: Array[Bullet]

@export var fire_rate: float = 0.5
@export var shoot_point: Marker2D

@export var character: CharacterBase
var sprite: AnimatedSprite2D

var _set_function: int:
	set(new_value):
		_set_function = new_value
		if not is_mutated and not bullets.is_empty():
			currentBullet = bullets[0]


func _ready() -> void:
	_set_function = 1
	call_deferred("_resolve_references")


func _resolve_references() -> void:
	if not is_instance_valid(character):
		character = get_parent() as CharacterBase

	if is_instance_valid(character):
		sprite = character.get_node_or_null("Sprite")
	else:
		sprite = null


func fire() -> void:
	if not can_fire:
		return
	if not is_instance_valid(character) or not is_instance_valid(sprite) or not is_instance_valid(shoot_point) or currentBullet == null:
		return

	can_fire = false

	# if the entity has this component and the "attacking" animation
	# set animation depending on speed
	var old_animation_speed = sprite.sprite_frames.get_animation_speed("attacking")
	if sprite.sprite_frames.has_animation("attacking"):
		sprite.sprite_frames.set_animation_speed("attacking", sprite.sprite_frames.get_animation_speed("attacking") / fire_rate)

	if "States" in character:
		character.current_state = character.States.ATTACKING

	#region initialize bullet
	var bullet_path = currentBullet.scene_file_path
	var bullet = GlobalFunc.instantiate_node(bullet_path)
	bullet.bullet_sprite = currentBullet.bullet_sprite
	bullet.damage = currentBullet.damage
	bullet.bullet_life_time = currentBullet.bullet_life_time
	bullet.scale = currentBullet.scale
	bullet.global_position = shoot_point.global_position
	bullet.bullet_owner = character
	#endregion

	get_tree().current_scene.call_deferred("add_child", bullet)
	if $"..".attack_stop == true:
		await $"../Sprite".animation_finished
	await get_tree().create_timer(fire_rate).timeout

	if "States" in character:
		character.current_state = character.States.IDLE
	sprite.sprite_frames.set_animation_speed("attacking", old_animation_speed)
	can_fire = true
