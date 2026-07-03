extends Node2D

signal value_changed(value: float)

@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var step: float = 1.0
@export var value: float = 0.0:
	set(val):
		var clamped_val = clampf(val, min_value, max_value)
		if value != clamped_val:
			value = clamped_val
			if is_inside_tree():
				_update_visuals()
			value_changed.emit(value)

var _is_dragging: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _target_frame: int = 0
var _current_frame: float = 0.0

func _ready() -> void:
	_update_visuals()
	_current_frame = float(_target_frame)
	sprite.frame = _target_frame
	_setup_ui_control()

func _process(delta: float) -> void:
	if _current_frame != float(_target_frame):
		_current_frame = lerpf(_current_frame, float(_target_frame), 5.0 * delta)
		if abs(_current_frame - float(_target_frame)) < 0.5:
			_current_frame = float(_target_frame)
		sprite.frame = clampi(int(round(_current_frame)), 0, 100)

func _setup_ui_control() -> void:
	var tex = sprite.sprite_frames.get_frame_texture("default", 0)
	if not tex: return
	
	var input_area = Control.new()
	var tex_width = tex.get_width() * sprite.scale.x
	var tex_height = tex.get_height() * sprite.scale.y
	
	# Size the control to exactly match the sprite's visual dimensions
	input_area.custom_minimum_size = Vector2(tex_width, tex_height)
	input_area.size = Vector2(tex_width, tex_height)
	# Center the control over the sprite
	input_area.position = Vector2(-tex_width / 2.0, -tex_height / 2.0)
	
	# Ensure it consumes mouse inputs and relays them
	input_area.mouse_filter = Control.MOUSE_FILTER_STOP
	input_area.gui_input.connect(_on_gui_input)
	add_child(input_area)

func _update_visuals() -> void:
	var percent = (value - min_value) / (max_value - min_value)
	_target_frame = clampi(int(percent * 100), 0, 100)
	SoundManager.play_sound(SoundManager.SoundType.SLIDER)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_dragging = true
			_update_value_from_mouse()
		else:
			_is_dragging = false
			
	elif event is InputEventMouseMotion and _is_dragging:
		_update_value_from_mouse()

func _update_value_from_mouse() -> void:
	var local_mouse = get_local_mouse_position()
	var tex = sprite.sprite_frames.get_frame_texture("default", 0)
	if not tex: return
	
	var width = tex.get_width() * sprite.scale.x
	var half_width = width / 2.0
	
	# Map the local X position to a 0.0 - 1.0 percentage
	var percent = (local_mouse.x + half_width) / width
	percent = clampf(percent, 0.0, 1.0)
	
	var new_value = min_value + (percent * (max_value - min_value))
	if step > 0:
		new_value = snappedf(new_value, step)
		
	self.value = new_value
