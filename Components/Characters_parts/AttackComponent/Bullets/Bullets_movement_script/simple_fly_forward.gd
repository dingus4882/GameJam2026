extends Bullet



func _physics_process(delta: float) -> void:
	position += direction * bullet_speed * delta
	
