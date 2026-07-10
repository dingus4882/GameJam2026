extends CollisionShape2D

var _is_triggered := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# This script should be a child of an Area2D node to work.
	# We connect to the parent's `body_entered` signal.
	var parent_area := get_parent()
	
	parent_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _is_triggered:
		return

	# Check if the colliding body is a character.
	if body is CharacterBase:
		_is_triggered = true
		var character: CharacterBase = body
		character.health_component.current_health = character.health_component.max_health

		get_parent().queue_free()
