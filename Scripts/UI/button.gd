extends Button

func hover_start():
	$hover.visible = true

func hover_end():
	$hover.visible = false

func on_press():
	SoundManager.play_sound(SoundManager.SoundType.BUTTON)

@export var is_this_storage : bool = false

func _process(delta: float) -> void:
	if is_this_storage:
		visible = !VariableController.is_in_fight
