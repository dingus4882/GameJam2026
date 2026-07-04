class_name  JumpComponent
extends Node

@onready var parent_node = get_node("..")

@export var  JUMP_VELOCITY:float = -450.0
# Called when the node enters the scene tree for the first time.
@export var max_extra_jumps: int = 3
@export var koyote_time:float = 1.0

var first_jump:bool = false
var koyote_jump:bool = false
var koyote_count:int = 0
var anti_koyote:bool = false
var extra_jumps:int = 0:
	set(new_value):
		if first_jump == true:
			first_jump = false

			return
		extra_jumps = new_value
		if first_jump == false and parent_node.is_on_floor():
			
			
			first_jump = true
			koyote_jump = true
			jump()
			
			
		if not parent_node.is_on_floor() :
			#print($Coyote_jump.get_child_count())
			if koyote_jump == false and $Coyote_jump.get_child_count() == 1:

				first_jump = true
				koyote_jump = true
				#print(extra_jumps)
				jump()
			if koyote_jump == false and $Coyote_jump.get_child_count() == 0:
				first_jump = false
				koyote_jump = true
				
				jump()

func print_packet():
	print("ran!!!")
	print(first_jump)
	print(extra_jumps)
	print(koyote_jump)
	print(koyote_count)



func jump():

	if  first_jump == false and parent_node.is_on_floor():
		
		extra_jumps = max_extra_jumps
		return
	if not parent_node.is_on_floor():
		if koyote_jump == false and $Coyote_jump.get_child_count() == 1:
			#print("ran")
			extra_jumps = max_extra_jumps
			return
		if koyote_jump == false and $Coyote_jump.get_child_count() == 0:
			#print_packet()

			extra_jumps = max_extra_jumps
			return
			
	if extra_jumps == 0 and first_jump == false:
		
		return
	parent_node.velocity.y = JUMP_VELOCITY
	extra_jumps -= 1
	
var temp_timer
func _physics_process(_delta):
				
	#Timer
	if not parent_node.is_on_floor() and $Coyote_jump.get_child_count() == 0 \
		and koyote_count == 0:
		koyote_count += 1
		anti_koyote = true

		temp_timer = GlobalFunc.set_up_timer($Coyote_jump,koyote_time,true,true)
	
	if parent_node.is_on_floor() and anti_koyote == true and koyote_count > 0:
		#print("raner")
		if $Coyote_jump.get_child_count() != 0:
			get_node("Coyote_jump").remove_child(temp_timer)
		
		koyote_jump = false
		anti_koyote = false
		koyote_count = 0
