class_name Effect_Parasite
extends Node

var host: CharacterBase
@export var effect_script: Script

func _ready():
	if effect_script == null and get_script() != null:
		effect_script = get_script() 
		set_script(null)
	#print(get_script())


func activate_parasite(host_):
	host = host_
	set_script(effect_script)
	#print(parent)
	#print(get_script())
