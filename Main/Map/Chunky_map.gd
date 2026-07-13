class_name Chunk_loader
extends TileMapLayer

@export var layers: Array[TileMapLayer]
@export var player: CharacterBase



##chunk size use child layer's tiles as a unit
@export var tile_ratio : Vector2i = Vector2i (32,32)
@export var chunk_size: Vector2i = Vector2i (16,16)
@export var render_distance: Vector2i = Vector2i (3,3)
@export var off_set: Vector2i = Vector2i (-1,-1)

var layers_data: Array[TileMapLayer]


var scene_path = scene_file_path.get_basename()
var current_chunk_id: Vector2i = Vector2i (0,0):
	set(value):
		if current_chunk_id.x != value.x and current_chunk_id.y != value.y:
			current_chunk_id = value
			#print(current_chunk_id)
			#print(current_chunk_id)
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
	self.tile_set.tile_size = chunk_size * tile_ratio
	
	
	for layer in layers:
		layers_data.append(layer.duplicate())
		
		var temp_size = layer.tile_set.tile_size
		layer.tile_set = tile_set.duplicate()
		layer.clear()
		layer.tile_set.tile_size = temp_size
		
		
	


func global_to_cell_id(global):
	current_chunk_id = local_to_map(global)

func load_chunk(chunk_id: Vector2i):
	for x in chunk_size.x:
		for y in chunk_size.y:
			var temp_cords = chunk_size * tile_ratio * chunk_id  + Vector2i(x,y)
			

			for index in len(layers):
				var temp_atlas_cords = layers_data[index].get_cell_atlas_coords(temp_cords)
				var temp_source_id = layers_data[index].get_cell_source_id(temp_cords)
				var temp_temp_cords = layers_data[index].local_to_map(temp_cords)
				
				if x== 1 and y == 1 and index == 2:
					print(temp_temp_cords)

					print(layers_data[index].get_used_cells())
					#
					#print(temp_atlas_cords)
					#print(temp_source_id)
					pass
				layers[index].set_cell(temp_temp_cords,temp_source_id,temp_atlas_cords)
	#
	#
	
func deload_chunk(chunk_id: Vector2i):
	for x in chunk_size.x:
		for y in chunk_size.y:
			var temp_cords = chunk_size * chunk_id * tile_ratio + Vector2i(x,y)
			for index in len(layers):
				layers[index].set_cell(temp_cords)

func _process(_delta):
	
	pass
	
	
