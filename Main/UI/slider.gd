@tool
extends Node2D

# Emitted when the slider's value changes.
signal value_changed(value: float)

# The slider's minimum value.
@export var min_value: float = 0.0
# The slider's maximum value.
@export var max_value: float = 100.0
# The snapping increment. If greater than 0, the value will snap to multiples of this.
@export var step: float = 1.0
# The current value of the slider.
@export var value: float = 0.0:
	set(new_value):
		var clamped_val = clampf(new_value, min_value, max_value)
		if step > 0:
			clamped_val = snappedf(clamped_val, step)
		
		if value != clamped_val:
			value = clamped_val
			if is_inside_tree() and progress_bar:
				progress_bar.value = value
			value_changed.emit(value)

@onready var progress_bar: TextureProgressBar = $TextureProgressBar

var _is_dragging: bool = false

func _ready() -> void:
	if not progress_bar:
		push_error("Slider script requires a child node of type TextureProgressBar.")
		return
	
	# Configure the child progress bar from our exported properties.
	progress_bar.min_value = min_value
	progress_bar.max_value = max_value
	progress_bar.step = step
	progress_bar.value = value
	
	# Connect to the child's gui_input signal to handle dragging.
	progress_bar.gui_input.connect(_on_gui_input)
	# Connect to our own value_changed signal to play sounds.
	value_changed.connect(_on_value_changed_sound)

func _on_value_changed_sound(_new_value: float) -> void:
	# Don't play sounds in the editor.
	if Engine.is_editor_hint():
		return
	
	# The original script played a sound on value change.
	# Assuming SoundManager is an autoload singleton.
	if not Engine.is_editor_hint() and SoundManager:
		SoundManager.play_sound(SoundManager.SoundType.SLIDER)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_dragging = true
			_update_value_from_mouse(event.position)
			get_viewport().set_input_as_handled()
		else:
			_is_dragging = false
			
	elif event is InputEventMouseMotion and _is_dragging:
		_update_value_from_mouse(event.position)
		get_viewport().set_input_as_handled()

func _update_value_from_mouse(mouse_pos: Vector2) -> void:
	# Ensure size.x is not zero to avoid division by zero.
	if progress_bar.size.x == 0:
		return

	# Map the local X position (relative to the progress bar) to a 0.0 - 1.0 percentage.
	var percent = mouse_pos.x / progress_bar.size.x
	percent = clampf(percent, 0.0, 1.0)
	
	# Calculate the new value based on the percentage.
	var new_value = lerp(min_value, max_value, percent)
	
	# Set the value. The custom setter will handle snapping, clamping, updating the
	# child progress bar, and emitting the value_changed signal.
	self.value = new_value
