extends CharacterBody2D

@export var speed = 500.0
@export var jump_velocity = -600.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	
	_update_animation()

func _update_animation():
	# Flip the sprite based on horizontal velocity.
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true

	# Determine which animation to play.
	var new_anim = "idle"
	if is_on_floor() and not is_zero_approx(velocity.x):
		new_anim = "walk"

	# This check prevents the animation from restarting on every frame.
	if animated_sprite.animation != new_anim:
		animated_sprite.play(new_anim)
