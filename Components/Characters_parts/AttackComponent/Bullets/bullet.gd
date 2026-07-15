class_name Bullet
extends Area2D

@export var damage: float = 10
@export var bullet_speed: float = 300.0
@export var bullet_sprite: Texture2D
@export var bullet_life_time: float = -1.0


@export var is_library: bool = false	
var bullet_owner:CharacterBase


var direction: Vector2 = Vector2.ZERO
func _ready():
	
	if is_library:
		position.y = 10000
	
	
	
	get_node("Sprite").texture = bullet_sprite
	self.connect("body_entered",do_bullet_thing)
	
	if bullet_life_time >= 0 :
		
		await get_tree().create_timer(bullet_life_time).timeout
		print("an")
		queue_free()




func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_library:
		queue_free()


func do_bullet_thing(body):

	if body.has_node("HealthComponent") and (bullet_owner != body):

		body.get_node("HealthComponent").take_damage(damage)
		if not is_library:
			queue_free()
