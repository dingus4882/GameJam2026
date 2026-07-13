class_name Chunk_loader
extends TileMapLayer

@export var layers: Array[TileMapLayer]
@export var player: CharacterBase



##chunk size use child layer's tiles as a unit
@export var chunk_size: Vector2i = Vector2i (16,16)
@export var render_distance: Vector2i = Vector2i (3,3)
@export var off_set: Vector2i = Vector2i (-1,-1)

var layers_data: Array[TileMapLayer]


var scene_path = scene_file_path.get_basename()
var current_chunk_id: Vector2i = Vector2i (0,0):
	set(value):
		current_chunk_id = value
		
		for x in render_distance.x:
			for y in render_distance.y:
				var chunk_id = Vector2i (x,y)  + off_set + current_chunk_id
				
				
				if get_cell_tile_data(chunk_id) == null:
					set_cell(chunk_id,0,Vector2i(0,0))
					load_chunk(chunk_id)
				else :
					set_cell(chunk_id)
					deload_chunk(chunk_id)


func _ready():
	player.connect("position_changed",global_to_cell_id)
	self.tile_set.tile_size = chunk_size
	
	
	for layer in layers:
		layers_data.append(layer.tile_set)
		var temp_size = layer.tile_set.tile_size
		layer.tile_set = tile_set.new()
		layer.clear()
		layer.tile_set.tile_size = temp_size
		
		
	


func global_to_cell_id(global):
	current_chunk_id = local_to_map(global)

func load_chunk(cords: Vector2i):
	for x in chunk_size.x:
		for y in chunk_size.y:
			var temp_cords = chunk_size * cords + Vector2i(x,y)
			
			for index in len(layers):
				var temp_atlas_cords = layers_data[index].get_cell_atlas_coords(temp_cords)
				var temp_source_id = layers_data[index].get_cell_source_id(temp_cords)
				
				
				
				layers[index].set_cell(temp_cords,temp_atlas_cords,temp_source_id)
	
	
	
func deload_chunk(cords: Vector2i):
	for x in chunk_size.x:
		for y in chunk_size.y:
			var temp_cords = chunk_size * cords + Vector2i(x,y)
			
			for index in len(layers):
				layers[index].set_cell(temp_cords)

func _process(_delta):
	
	pass
	
	
