extends Effect_Parasite

@export var shield_duration:float = 15
@export var shield_rebound_count:int = 3
@export var shield_offset:Vector2 = Vector2 (30,0)
@export var rock_shield_path:String

var shield_instance
@onready var store 

func _ready():
	
	if host:

		print("start")
		summon_shield()
		burn_out()



	

func summon_shield():
	
	#print(parent)
	if host.has_node("Rock_shield") and host.has_node(NodePath(self.name)):
		host.get_node(NodePath(self.name)).queue_free()
		host.get_node("Rock_shield").queue_free()
		
		
	shield_instance  = GlobalFunc.instantiate_node(rock_shield_path)
	host.add_child(shield_instance)
	#print("ahh")

	shield_instance.connect("area_entered",bounce_back)
	shield_instance.connect("body_entered",bounce_back)
	shield_instance.position = shield_offset

func bounce_back(body:Node):
	if shield_rebound_count == 0:
		if shield_instance:
			shield_instance.queue_free()
		queue_free()
	#print(shield_rebound_count)
	if body is Bullet:
		
		body.direction = -body.direction
	if body is CharacterBase:
		body.get_node("Base_Ai").turn_around(self)
		
		if body.get_node("Base_Ai").has_node("Rolling_Ai"):
			print("return_to_sender")
			body.get_node("Base_Ai/Rolling_Ai").change_friendship()
	shield_rebound_count -= 1
	

func burn_out():
	await get_tree().create_timer(shield_duration).timeout
	if shield_instance:
		shield_instance.queue_free()
	
	queue_free()
