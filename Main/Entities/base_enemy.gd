class_name BaseEnemy
extends CharacterBody2D

@export var speed: float = 100.0

var direction: float = 1.0
var is_following: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	if ray_cast_right.is_colliding():
		direction = -1.0
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1.0
		animated_sprite.flip_h = false
		
	velocity.x = direction * speed

	move_and_slide()