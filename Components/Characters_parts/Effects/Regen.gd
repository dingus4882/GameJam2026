extends Effect_Parasite


@export var heal:int= 2
@export var duration:float = 3
@export var heal_interval:float = 0.2

func _ready():
	if host:
		heal_instance()
		burn_out()

func heal_instance():
	#print(host)
	if host.health_component:
		host.health_component.heal_damage(heal)
	await get_tree().create_timer(heal_interval).timeout
	heal_instance()

func burn_out():
	await get_tree().create_timer(duration).timeout
	queue_free()
