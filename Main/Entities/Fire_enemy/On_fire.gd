extends Effect_Parasite


@export var burn_damage:int= 2
@export var burn_duration:float = 3
@export var burn_interval:float = 0.2

func _ready():
	if host:
		damage_instance()
		burn_out()

func damage_instance():
	#print(parent)
	if host.health_component:
		host.health_component.take_damage(burn_damage)
	await get_tree().create_timer(burn_interval).timeout
	damage_instance()

func burn_out():
	await get_tree().create_timer(burn_duration).timeout
	queue_free()
