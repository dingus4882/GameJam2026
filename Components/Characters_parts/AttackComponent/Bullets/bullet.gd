class_name Bullet
extends Area2D

signal expire

@export var damage: float = 10
@export var bullet_speed: float = 300.0
@export var bullet_sprite_overide: Texture2D
@export var bullet_sprites_overide: AnimatedTexture

@export var bullet_life_time: float = -1.0


@export var is_library: bool = false	
var bullet_owner:CharacterBase


var direction: Vector2 = Vector2.ZERO
func _ready():
	
	if is_library:
		position.y = 10000
	
	
	if bullet_sprite_overide != null:
		get_node("Sprite").texture = bullet_sprite_overide
	
	if bullet_sprites_overide != null:
		get_node("Sprite").texture = bullet_sprite_overide
		
	self.connect("body_entered",do_bullet_thing)
	
	if bullet_life_time >= 0 and is_library == false:
		
		await get_tree().create_timer(bullet_life_time).timeout
		fracture()
		
		emit_signal("expire")
		queue_free()




func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_library:
		queue_free()


func do_bullet_thing(body):
	fracture()
	if body.has_node("HealthComponent") and (bullet_owner != body):
		body.get_node("HealthComponent").take_damage(damage, bullet_owner)
		
		#print(list_of_effects)
		if body:
			resolve_extra_effects(body)
		
		if not is_library:
			queue_free()

@export var list_of_spliter: Array[String]

func fracture():
	#print(list_of_spliter)
	for i in list_of_spliter:
		#print(i)
		var the_fracture = GlobalFunc.instantiate_node(i)
		the_fracture.global_position = global_position
		get_parent().add_child(the_fracture)



@export var list_of_effects: Array[Effect_Parasite]
func resolve_extra_effects(body):
	for i in list_of_effects:
		print("ow")
		var effect = i.duplicate()
		effect.activate_parasite(body)
		body.add_child(effect)
		
		
