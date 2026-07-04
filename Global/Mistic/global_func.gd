extends Node



func instantiate_node(scene:String, has_args:bool = false,...args):
	var loaded_scene = load(scene)




	var instance = loaded_scene.instantiate()
	if has_args:
		var instace_properties_list = instance.get_script_property_list()
		for i in len(args):
			instance.set(instace_properties_list[i].name, args[i])
	return instance
	
	
func play_smoothly(anim_player, animation:String, is_backward:bool = false):
	var store = 0  - 1 * ( int( is_backward))
	#print(is_backward)
	if anim_player.current_animation != "" :
		store = anim_player.current_animation_position
		
	var start = store
	var end = -1
	var speed = anim_player.speed_scale * (int(is_backward) * (-2) + 1)

	if is_backward == true:
		var temp = start
		start = end
		end = temp

	anim_player.call("play_section",animation,start,end,-1,speed,is_backward)
	#AnimationPlayer



func get_turtle_location():

	return get_node("/root/" + GlobalVar.current_level_name + "/Level_editor/Entities_container/Turtle")



func set_up_timer(node, duration, autostart: bool = false, auto_free_itself:bool = false, ... connect_funcs):
	var timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = autostart
	if auto_free_itself:
		timer.connect("timeout", timer.queue_free)
		
	
	node.add_child(timer)
	for i in connect_funcs:
		timer.connect("timeout", i)
	return timer
	
	
func next_scene(next_level_scene):
	get_tree().change_scene_to_file.call_deferred(next_level_scene.resource_path)
	
	
	
	
	
func end_everthing():
	get_tree().quit()
	#String
func get_name_of_scene(scene):
	var temp =  scene.resource_path.get_file().get_basename()
	return temp[0].to_upper() + temp.substr(1)
	
	

 
