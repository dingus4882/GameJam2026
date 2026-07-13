class_name CharacterBase
extends CharacterBody2D

enum States { IDLE, JUMP, FALL, MOVE, ATTACKING}

var current_state: States = States.IDLE



@export var speed = 200.0
@export var is_gravity_on: bool = true

## Use when character_sprite need to be side way
@export var flip_h_or_v:bool = false
var flip: String

const  GRAVITY = 980.0
@export var disable_auto_turn: bool

var last_direction : float 
var direction : float:
	set(new_value):
		#flip = "flip_h".repeat( int(not flip_h_or_v) ) + "flip_v".repeat( int(flip_h_or_v) )
		var x = scale.x * (int(not flip_h_or_v)    * 2 - 1)
		var y = scale.y * (int( flip_h_or_v)    * 2 - 1)
		var scalar = Vector2(x,y)

		if last_direction != new_value and new_value != 0:
			
			set("scale",- scalar)
			
			last_direction = new_value

				
					
			
		direction = new_value



## if the sprite looks toward the right then change this instead of flip_h [br]
## tho flip_h still works fine
@export var is_sprite_towards_the_right:bool



@export var health_component: HealthComponent 
@export var attack_component: AttackComponent 

@export var sprite: AnimatedSprite2D 

@export var direction_point: Marker2D


func _ready() -> void:


	

	last_direction = float(is_sprite_towards_the_right) * 2 - 1
	
	
	





	
@export var attack_stop:bool = false 
func movement(_delta: float): 
	
	#SideNote: JUMP/ FALL States take priority over MOVE State.
	if current_state == States.ATTACKING and (sprite.animation == "attacking" and  attack_stop):
		return
	if direction:

	
		#sprite.flip_h = bool(direction - 1)   			less if checking version
		#marker.position.x = 12.0 * direction
		
		
		velocity.x = speed * direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	
	
	#region animation_overwrite
	if current_state == States.ATTACKING:
		return
	
	#endregion
	
	#region handles movement animations
	if not is_on_floor():
		if velocity.y < 0:
			current_state = States.JUMP
		else:
			current_state = States.FALL
	elif direction:
		current_state = States.MOVE
	else:
		current_state = States.IDLE
	#endregion
	
	
func animation() -> void:
	
	match current_state:
		States.IDLE:
			sprite.play("idle")
		States.MOVE:
			sprite.play("walk")
		States.JUMP:
			sprite.play("jump")
		States.ATTACKING:
			sprite.play("attacking")



func _physics_process(_delta):
	if TimeManager._menu_open_count > 0:
		return

	
	


	#region disable
	if len(GlobalVar.source_of_disability) > 0:
		return


	#endregion
	if not is_on_floor() and is_gravity_on:
		velocity.y += GRAVITY * _delta
	move_and_slide()
	
	
	
signal position_changed (global_position)
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		position_changed.emit (global_position)
