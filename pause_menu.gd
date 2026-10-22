extends CanvasLayer

signal resume_pressed
signal main_menu_pressed

@onready var root: Control = $Root
@onready var resume_button: Button = $Root/Content/ButtonContainer/ResumeButton
@onready var main_menu_button: Button = $Root/Content/ButtonContainer/MainMenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	resume_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	main_menu_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		close()
		resume_pressed.emit()


func open() -> void:
	visible = true
	resume_button.grab_focus()


func close() -> void:
	visible = false


func is_open() -> bool:
	return visible


func _on_resume_pressed() -> void:
	close()
	resume_pressed.emit()


func _on_main_menu_pressed() -> void:
	close()
	main_menu_pressed.emit()
