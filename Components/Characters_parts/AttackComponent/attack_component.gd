
class_name AttackComponent
extends Node

var is_mutated: bool = false
var currentBullet: Bullet
var can_fire = true

@export var bullets: Array[Bullet] 

@export var fire_rate: float = 0.5
@export var shoot_point: Marker2D


@export var character: CharacterBase
var sprite:AnimatedSprite2D 

var _set_function: int:
	set(new_value):
		_set_function = new_value
		if not is_mutated:
			currentBullet = bullets[0]

		sprite = character.get_node("Sprite")

		





func _ready() -> void:
	_set_function = 1


func fire() -> void:
	
	if not can_fire:
		return
	can_fire = false
	
	# if the entity has this component and the "actacking" animation
	# set animation depending on speed
	var old_animation_speed = sprite.sprite_frames.get_animation_speed("attacking")
	if sprite.sprite_frames.has_animation("attacking") :
		sprite.sprite_frames.set_animation_speed("attacking"\
		,sprite.sprite_frames.get_animation_speed("attacking") / fire_rate)
		
		

		

	
	if "States" in character:
		character.current_state = character.States.ATTACKING
		
	#AnimatedSprite2D
	

	#region initialize bullet
	
	var bullet_path = currentBullet.scene_file_path

	var bullet = GlobalFunc.instantiate_node(bullet_path)
	
	bullet.bullet_sprite = currentBullet.bullet_sprite
	bullet.damage = currentBullet.damage
	bullet.scale = currentBullet.scale
	
	bullet.global_position = shoot_point.global_position

	#bullet.direction = (Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT)
	
	bullet.bullet_owner = character
	#endregion
	
	
	get_tree().current_scene.call_deferred("add_child",bullet)
	if $"..".attack_stop == true:
		await $"../Sprite".animation_finished
	await get_tree().create_timer(fire_rate).timeout
	

	if "States" in character:
		character.current_state = character.States.IDLE
	sprite.sprite_frames.set_animation_speed("attacking",old_animation_speed)
	can_fire = true
	
