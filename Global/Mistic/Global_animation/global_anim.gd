extends Node

var container = self


func fade_in(is_backward: bool= false):
	GlobalFunc.play_smoothly(container.get_node("fade_in/Handle_screen_fade"),"fade_in",is_backward)
func global_fade_in(is_backward: bool= false):
	GlobalFunc.play_smoothly(container.get_node("fade_in_global/Handle_screen_fade"),"fade_in",is_backward)

func flip_anim_track_h(Anim: Animation):
	for track_id in Anim.get_track_count():
		for key_id in Anim.track_get_key_count(track_id):
			var value = Anim.track_get_key_value(track_id,key_id)
			
			if  typeof(value) == TYPE_FLOAT:
				#print(direction)
				Anim.track_set_key_value(track_id,key_id,(-1) * value)

			elif typeof(value) == TYPE_VECTOR2 :
				var temp: Vector2 = Vector2((-1) * value.x,value.y)
				Anim.track_set_key_value(track_id,key_id,temp)
				
				
func shake_camera(camera: Camera2D, amount_of_shake = 3, intensity_of_shake = 30, time_between_each_move = 0.1):
	camera.set_process(false)
	camera.set_physics_process(false)
	var old_camera_position = camera.global_position
	
	@warning_ignore("integer_division")
	camera.global_position.x += intensity_of_shake / 2
	
	for i in amount_of_shake:
		await get_tree().create_timer(time_between_each_move).timeout
		camera.global_position.x -= intensity_of_shake
		await get_tree().create_timer(time_between_each_move).timeout
		camera.global_position.x += intensity_of_shake
	
	camera.global_position = old_camera_position
	camera.set_process(true)
	camera.set_physics_process(true)
