class_name Chunk_loader
extends TileMapLayer

@export var layers: Array[TileMapLayer]
@export var player: CharacterBase




@export var chunk_size: Vector2i = Vector2i (16,16)
@export var render_distance: Vector2i = Vector2i (3,3)
@export var off_set: Vector2i = Vector2i (-1,-1)

var layers_data: Array[TileMap]


var scene_path = scene_file_path.get_basename()
var current_chunk_id: Vector2i = Vector2i (0,0):
	set(value):
		current_chunk_id = value
		
		for x in render_distance.x:
			for y in render_distance.y:
				var chunk_id = Vector2i (x,y)  + off_set
				
				
				if get_cell_tile_data(chunk_id) == null:
					pass


func _ready():
	player.connect("position_changed",global_to_cell_id)
	self.tile_set.tile_size = chunk_size
	
	
	for layer in layers:
		layers_data.append(layer.tile_set)
		var temp_size = layer.tile_set.tile_size
		layer.tile_set = TileSet.new()
		layer.tile_set.tile_size = temp_size
		
		
	


func global_to_cell_id(global):
	current_chunk_id = local_to_map(global)

func load_chunk(cords: Vector2i):
	for layer in layers:
		layer.tile_set = load(scene_file_path.get_base_dir() + "/" +layer.name.to_lower() + ".tres")
	
	
	
func deload_chunk(cords: Vector2i):
	for layer in layers:
		layer.tile_set = null
		
func _process(_delta):
	
	pass
	
	
