class_name Chunky_map
extends Area2D

@export var levels: Array[TileMapLayer]
var scene_path = scene_file_path.get_basename()


func _ready():
	connect("area_entered",load_map)
	connect("area_exited",deload_map)
	
	collision_layer = 0
	collision_mask = (1 << 7)
	
	for layer in levels:
		layer.tile_set = null



func load_map(_body):
	for layer in levels:
		layer.tile_set = load(scene_file_path.get_base_dir() + "/" +layer.name.to_lower() + ".tres")
	
	
	
func deload_map(_body):
	for layer in levels:
		layer.tile_set = null
