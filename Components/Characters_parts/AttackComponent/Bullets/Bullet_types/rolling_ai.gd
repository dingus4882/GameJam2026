extends Node

@export var is_friend:bool =false



func _ready():
	$"..".connect("turned_around",turn_check)
	
	if is_friend:
		$"../../Direction_point/Attack_range".set_collision_mask_value(3,true)
		$"../../AttackComponent/Hurt_box".set_collision_mask_value(3,true)
		$"../../Direction_point/Attack_range".set_collision_mask_value(2,false)
		$"../../AttackComponent/Hurt_box".set_collision_mask_value(2,false)
		return
		
	$"../../Direction_point/Attack_range".set_collision_mask_value(3,false)
	$"../../AttackComponent/Hurt_box".set_collision_mask_value(3,false)
	$"../../Direction_point/Attack_range".set_collision_mask_value(2,true)
	$"../../AttackComponent/Hurt_box".set_collision_mask_value(2,true)
@export var limited_turning = 3



func turn_check():
	if limited_turning == 0:
		$"../..".queue_free()
	limited_turning -= 1
func change_friendship():
	is_friend = not is_friend
	
	if is_friend:
		$"../../Direction_point/Attack_range".set_collision_mask_value(3,true)
		$"../../AttackComponent/Hurt_box".set_collision_mask_value(3,true)
		$"../../Direction_point/Attack_range".set_collision_mask_value(2,false)
		$"../../AttackComponent/Hurt_box".set_collision_mask_value(2,false)
		return
		
	$"../../Direction_point/Attack_range".set_collision_mask_value(3,false)
	$"../../AttackComponent/Hurt_box".set_collision_mask_value(3,false)
	$"../../Direction_point/Attack_range".set_collision_mask_value(2,true)
	$"../../AttackComponent/Hurt_box".set_collision_mask_value(2,true)
