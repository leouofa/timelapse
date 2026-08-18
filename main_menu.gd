extends Control


func _ready() -> void:
	var has_save := Dialogic.Save.has_slot(Dialogic.Save.get_default_slot())
	$VBoxContainer/ContinueButton.visible = has_save


func _on_new_game_pressed() -> void:
	var slot := Dialogic.Save.get_default_slot()
	if Dialogic.Save.has_slot(slot):
		Dialogic.Save.delete_slot(slot)
	visible = false
	Dialogic.start("first_timeline_kitchen")


func _on_continue_pressed() -> void:
	visible = false
	Dialogic.Save.load()
