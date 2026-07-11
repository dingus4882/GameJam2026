extends CollisionShape2D

var _is_triggered := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# This script should be a child of an Area2D node to work.
	# We connect to the parent's `body_entered` signal.
	var parent_area := get_parent()
	if not parent_area is Area2D:
		push_error("HealCollider's parent must be an Area2D.")
		return
	# Connect to both body_entered and area_entered to be more robust,
	# as the character might be detected via its PhysicsBody or a child Area2D.
	parent_area.body_entered.connect(_on_entered)
	parent_area.area_entered.connect(_on_entered)

func _on_entered(node: Node) -> void:
	if _is_triggered:
		return

	var character: CharacterBase = null
	# The entering node could be the character itself...
	if node is CharacterBase:
		character = node
	# ... or it could be a child node (like a hitbox Area2D),
	# in which case we check its owner.
	elif node.get_owner() is CharacterBase:
		character = node.get_owner()

	if character:
		_is_triggered = true
		character.health_component.fully_heal()
		get_parent().queue_free()
