class_name AttackComponent
extends Node

var is_mutated: bool = false

var can_fire = true

@export var bullets: Array[Bullet]
@export var currentBullet: Bullet

@export var fire_rate: float = 0.5
@export var shoot_point: Marker2D

@export var character: CharacterBase

var sprite: AnimatedSprite2D 
@export var animation_player: AnimationPlayer
@export var skip_sprite_animation:bool = false
@export var skip_animation_player:bool = false
@export var skip_shooting_prevention:bool = false
@export var skip_attack_speed_check:bool = false

## an area on the map that dictate if it can fire or not [br]
## if left w or h is negative will not run
@export var resricted_area: Rect2i = Rect2i(0,0,-1,-1) 





func _ready() -> void:
	call_deferred("_resolve_references")


func _resolve_references() -> void:
	if not is_instance_valid(character):
		character = get_parent() as CharacterBase

	if is_instance_valid(character):
		sprite = character.get_node_or_null("Sprite")
		
	else:
		sprite = null


func fire() -> void:
	
	if resricted_area.size.x > 0 and  resricted_area.size.y > 0:
		if not resricted_area.has_point( shoot_point.global_position ):
			return
	
	
	if not can_fire:
		return
	if not is_instance_valid(character) or not is_instance_valid(sprite) or not is_instance_valid(shoot_point) or currentBullet == null:
		return

	if not skip_shooting_prevention:
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
	
	bullet.bullet_sprite_overide = currentBullet.bullet_sprite_overide 
	bullet.bullet_sprites_overide = currentBullet.bullet_sprites_overide 
	
	bullet.damage = currentBullet.damage
	bullet.bullet_life_time = currentBullet.bullet_life_time
	bullet.scale = currentBullet.scale
	bullet.global_position = shoot_point.global_position
	bullet.bullet_owner = character
	#endregion

	get_tree().current_scene.call_deferred("add_child", bullet)
	if $"..".attack_stop == true:
		if sprite and not skip_sprite_animation:
			await $"../Sprite".animation_finished
		if animation_player  and not skip_animation_player:
			await animation_player.animation_finished
		
			
	if not skip_attack_speed_check:
		await get_tree().create_timer(fire_rate).timeout

	if "States" in character:
		character.current_state = character.States.IDLE
	sprite.sprite_frames.set_animation_speed("attacking", old_animation_speed)
	if not skip_shooting_prevention:
		can_fire = true
