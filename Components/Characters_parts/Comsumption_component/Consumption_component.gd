class_name Consumption_component
extends Node


@export var list_of_effects: Array[Effect_Parasite]

func resolve_extra_effects(body:Node):# the victim getting the effects
	for i in list_of_effects:
		var effect = i.duplicate()
		effect.activate_parasite(body)
		body.add_child(effect)
