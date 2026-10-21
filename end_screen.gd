extends Control

signal play_again_pressed
signal main_menu_pressed
signal quit_pressed

@onready var content_container: VBoxContainer = $Content
@onready var play_again_button: Button = $Content/ButtonContainer/PlayAgainButton
@onready var main_menu_button: Button = $Content/ButtonContainer/MainMenuButton
@onready var quit_button: Button = $Content/ButtonContainer/QuitButton

var _tween: Tween


func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)


func fade_in(duration: float = 1.2) -> void:
	visible = true
	modulate.a = 0.0
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 1.0, duration)


func _on_play_again_pressed() -> void:
	play_again_pressed.emit()
	if get_parent() == get_tree().root:
		var slot := Dialogic.Save.get_default_slot()
		if Dialogic.Save.has_slot(slot):
			Dialogic.Save.delete_slot(slot)
		Dialogic.start("01_timeline")
		visible = false


func _on_main_menu_pressed() -> void:
	main_menu_pressed.emit()
	if get_parent() == get_tree().root:
		get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_quit_button_pressed() -> void:
	quit_pressed.emit()
	if get_parent() == get_tree().root:
		get_tree().quit()
