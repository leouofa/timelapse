extends Control

@onready var background: TextureRect = $Background
@onready var music: AudioStreamPlayer = $Music
@onready var menu_container: VBoxContainer = $VBoxContainer
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var end_screen: Control = $EndScreen
@onready var pause_menu: CanvasLayer = $PauseMenu

var _last_timeline: String = ""
var _is_in_game: bool = false


func _ready() -> void:
	for child in menu_container.get_children():
		if child is Button:
			child.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_update_continue_button()
	music.play()

	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

	end_screen.play_again_pressed.connect(_on_end_screen_play_again)
	end_screen.main_menu_pressed.connect(_on_end_screen_main_menu)
	end_screen.quit_pressed.connect(_on_end_screen_quit)

	pause_menu.resume_pressed.connect(_on_pause_menu_resume)
	pause_menu.main_menu_pressed.connect(_on_pause_menu_main_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE):
		if _can_open_pause_menu():
			get_viewport().set_input_as_handled()
			_open_pause_menu()


func _can_open_pause_menu() -> bool:
	return _is_in_game and not pause_menu.is_open() and not end_screen.visible and not menu_container.visible and Dialogic.current_timeline != null


func _open_pause_menu() -> void:
	Dialogic.paused = true
	pause_menu.open()


func _on_pause_menu_resume() -> void:
	Dialogic.paused = false


func _on_pause_menu_main_menu() -> void:
	Dialogic.paused = false
	Dialogic.Save.save()
	_last_timeline = ""

	var autosave_was_enabled: bool = Dialogic.Save.autosave_enabled
	Dialogic.Save.autosave_enabled = false

	await Dialogic.clear()
	if Dialogic.Styles.has_active_layout_node() and Dialogic.Styles.get_layout_node().is_inside_tree():
		Dialogic.Styles.get_layout_node().get_parent().remove_child(Dialogic.Styles.get_layout_node())
		Dialogic.Styles.get_layout_node().queue_free()

	Dialogic.Save.autosave_enabled = autosave_was_enabled
	_show_main_menu()


func _enter_game() -> void:
	_is_in_game = true
	background.visible = false
	menu_container.visible = false
	end_screen.visible = false
	pause_menu.close()
	music.stop()


func _show_main_menu() -> void:
	_is_in_game = false
	end_screen.visible = false
	pause_menu.close()
	_update_continue_button()
	background.visible = true
	menu_container.visible = true
	music.play()


func _update_continue_button() -> void:
	var has_save := Dialogic.Save.has_slot(Dialogic.Save.get_default_slot())
	continue_button.visible = has_save


func _on_new_game_pressed() -> void:
	var slot := Dialogic.Save.get_default_slot()
	if Dialogic.Save.has_slot(slot):
		Dialogic.Save.delete_slot(slot)
	_enter_game()
	Dialogic.start("01_timeline")


func _on_continue_pressed() -> void:
	_enter_game()
	Dialogic.Save.load()


func _on_timeline_started() -> void:
	if Dialogic.current_timeline:
		_last_timeline = Dialogic.current_timeline.get_identifier()
		if _last_timeline.is_empty():
			_last_timeline = Dialogic.current_timeline.resource_path.get_file().get_basename()


func _on_timeline_ended() -> void:
	if _last_timeline == "08_timeline":
		var slot := Dialogic.Save.get_default_slot()
		if Dialogic.Save.has_slot(slot):
			Dialogic.Save.delete_slot(slot)

		_is_in_game = false
		background.visible = false
		menu_container.visible = false
		end_screen.visible = true
		end_screen.fade_in()


func _on_end_screen_play_again() -> void:
	var slot := Dialogic.Save.get_default_slot()
	if Dialogic.Save.has_slot(slot):
		Dialogic.Save.delete_slot(slot)
	_enter_game()
	Dialogic.start("01_timeline")


func _on_end_screen_main_menu() -> void:
	_show_main_menu()


func _on_end_screen_quit() -> void:
	get_tree().quit()
