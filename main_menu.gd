extends Control

@onready var music: AudioStreamPlayer = $Music
@onready var menu_container: VBoxContainer = $VBoxContainer
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var end_screen: Control = $EndScreen

var _last_timeline: String = ""


func _ready() -> void:
	_update_continue_button()
	music.play()

	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

	end_screen.play_again_pressed.connect(_on_end_screen_play_again)
	end_screen.main_menu_pressed.connect(_on_end_screen_main_menu)
	end_screen.quit_pressed.connect(_on_end_screen_quit)


func _update_continue_button() -> void:
	var has_save := Dialogic.Save.has_slot(Dialogic.Save.get_default_slot())
	continue_button.visible = has_save


func _on_new_game_pressed() -> void:
	var slot := Dialogic.Save.get_default_slot()
	if Dialogic.Save.has_slot(slot):
		Dialogic.Save.delete_slot(slot)
	visible = false
	music.stop()
	Dialogic.start("01_timeline")


func _on_continue_pressed() -> void:
	visible = false
	music.stop()
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

		visible = true
		menu_container.visible = false
		end_screen.visible = true
		end_screen.fade_in()


func _on_end_screen_play_again() -> void:
	var slot := Dialogic.Save.get_default_slot()
	if Dialogic.Save.has_slot(slot):
		Dialogic.Save.delete_slot(slot)
	end_screen.visible = false
	visible = false
	Dialogic.start("01_timeline")


func _on_end_screen_main_menu() -> void:
	end_screen.visible = false
	_update_continue_button()
	menu_container.visible = true
	music.play()


func _on_end_screen_quit() -> void:
	get_tree().quit()
