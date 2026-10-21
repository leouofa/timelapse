extends Control

@onready var music: AudioStreamPlayer = $Music


func _ready() -> void:
	var has_save := Dialogic.Save.has_slot(Dialogic.Save.get_default_slot())
	$VBoxContainer/ContinueButton.visible = has_save
	music.play()


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
