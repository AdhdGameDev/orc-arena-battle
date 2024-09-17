extends Control


@onready var start_button: Button = $MarginContainer/HBoxContainer/StartButton
@onready var exit_button: Button = $MarginContainer/HBoxContainer/ExitButton


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
