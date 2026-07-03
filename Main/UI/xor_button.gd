extends Button
class_name XORButton

var buttons: Array = []
@export var other_categories: Array[XORButton] = []
@onready var hover_sprite: AnimatedSprite2D = get_node_or_null("Hover")
@onready var disabled_sprite: Sprite2D = get_node_or_null("disabled")

var is_group_open := false
var is_clicking := false

func _ready() -> void:
	for child in get_children():
		if child is Control and child != self:
			buttons.append(child)

	if not pressed.is_connected(_on_button_press):
		pressed.connect(_on_button_press)
	button_down.connect(_on_mouse_down)
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	if not focus_entered.is_connected(_on_mouse_entered):
		focus_entered.connect(_on_mouse_entered)
	if not focus_exited.is_connected(_on_mouse_exited):
		focus_exited.connect(_on_mouse_exited)
		
	_update_visual_state()

func _notification(what):
	if what == NOTIFICATION_DRAW:
		_update_visual_state()

func set_group_open(open: bool):
	is_group_open = open
	_update_visual_state()

func _update_visual_state():
	if disabled:
		#show disabled
		pass
	else:
		if disabled_sprite: 
			pass
		#if selected_sprite:
		#	selected_sprite.visible = is_group_open or is_clicking

		#if hover_sprite:
		#	hover_sprite.visible = true

	if is_group_open:
		self.modulate = Color(1.0, 1.0, 1.0)

func _on_mouse_entered():
	if not disabled:
		_update_visual_state()

func _on_mouse_exited():
	_update_visual_state()

func _on_mouse_down():
	if not disabled and hover_sprite:
		is_clicking = true
		_update_visual_state()
		await get_tree().create_timer(0.1).timeout
		is_clicking = false
		_update_visual_state()

func get_sibling_buttons() -> Array:
	return buttons

func _on_button_press():
	SoundManager.play_sound(SoundManager.SoundType.BUTTON)

	if not is_group_open:
		show_buttons(true)

# control visability of the buttons inside this category
func show_buttons(show = true):
	is_group_open = show
	_update_visual_state()
	
	if show:
		for button in buttons:
			button.visible = true

		for  other_category in other_categories:
			other_category.show_buttons(false)
	else:
		# Hide all buttons
		for button in buttons:
			button.visible = false
