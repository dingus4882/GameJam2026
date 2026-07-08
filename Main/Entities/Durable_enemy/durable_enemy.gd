extends "res://Main/Entities/base_enemy.gd"

class_name DurableEnemy

func _ready():
	# This enemy is slower but more durable.
	speed = 60.0
