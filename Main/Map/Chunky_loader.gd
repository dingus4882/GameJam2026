class_name Chunk_loader
extends TileMapLayer

@export var layers: Array[TileMapLayer]
@export var player: CharacterBase



##chunk size use child layer's tiles as a unit
@export var tile_ratio : Vector2i = Vector2i (32,32)
@export var chunk_size: Vector2i = Vector2i (16,16)
@export var render_distance: Vector2i = Vector2i (3,3)
@export var chunk_off_set: Vector2i = Vector2i (-1,-1)

var layers_data: Array[TileMapLayer]


var scene_path = scene_file_path.get_basename()
var current_chunk_id: Vector2i = Vector2i (0,0):
	set(new_chunk):
		if current_chunk_id.x != new_chunk.x or current_chunk_id.y != new_chunk.y:

			var the_chunk = Rect2i((chunk_off_set + new_chunk).x
								,(chunk_off_set + new_chunk).y
								,(render_distance ).x
								,(render_distance ).y)
			#print(current_chunk_id)
			#print(current_chunk_id)
			for x in render_distance.x:
				for y in render_distance.y:
					var chunk_id = Vector2i (x,y)  + chunk_off_set + new_chunk
					
					if x == 1 and y == 1:
						#print(chunk_id)
						pass
					
					
					if get_cell_tile_data(chunk_id) == null:
						set_cell(chunk_id,0,Vector2i(0,0))
						load_chunk(chunk_id)
					
					var old_chunk = Vector2i (x,y)  + chunk_off_set + current_chunk_id
					if not the_chunk.has_point(old_chunk):
						set_cell( old_chunk)
						deload_chunk(old_chunk)
			current_chunk_id = new_chunk



func _ready():
	player.connect("position_changed",global_to_cell_id)
	tile_set.tile_size = chunk_size * tile_ratio
	#print(tile_set.tile_size)
	
	for layer in layers:
		layers_data.append(layer.duplicate())
		

		layer.tile_set = layer.tile_set.duplicate()
		layer.clear()
		

	pass


func global_to_cell_id(global):
	current_chunk_id = local_to_map(global)

func load_chunk(chunk_id: Vector2i):
	for x in chunk_size.x:
		for y in chunk_size.y:
			var temp_global_cords = chunk_size * tile_ratio * chunk_id  + Vector2i(x,y) * tile_ratio
			

			for index in len(layers):
				var temp_map_cords = layers_data[index].local_to_map(temp_global_cords)
				var temp_atlas_cords = layers_data[index].get_cell_atlas_coords(temp_map_cords)
				var temp_source_id = layers_data[index].get_cell_source_id(temp_map_cords)
				
				if temp_source_id > -1:
					var source = layers_data[index].tile_set.get_source(temp_source_id)
					
					if source is TileSetAtlasSource:
						layers[index].set_cell(temp_map_cords,temp_source_id,temp_atlas_cords)
						
					if source is TileSetScenesCollectionSource:
						var alt_id = layers_data[index].get_cell_alternative_tile(temp_map_cords)
						layers[index].set_cell(temp_map_cords, temp_source_id,Vector2i.ZERO,alt_id)
	#
	#
	
func deload_chunk(chunk_id: Vector2i):
	for x in chunk_size.x:
		for y in chunk_size.y:
			var temp_global_cords = chunk_size * tile_ratio * chunk_id  + Vector2i(x,y) * tile_ratio
			for index in len(layers):
				var temp_map_cords = layers_data[index].local_to_map(temp_global_cords)
				layers[index].set_cell(temp_map_cords)

func _process(_delta):
	
	pass
	
	
