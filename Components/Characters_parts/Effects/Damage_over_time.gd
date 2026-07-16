extends Effect_Parasite


@export var damage:int= 2
@export var duration:float = 3
@export var damage_interval:float = 0.2

func _ready():
	if host:
		damage_instance()
		burn_out()

func damage_instance():
	#print(parent)
	if host.health_component:
		host.health_component.take_damage(damage)
	await get_tree().create_timer(damage_interval).timeout
	damage_instance()

func burn_out():
	await get_tree().create_timer(duration).timeout
	queue_free()
