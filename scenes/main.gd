extends Node2D


@onready var score: Label = $UI/MarginContainer/Score

var current_points: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.enemy_defeated.connect(_on_enemy_defeated)
	
	
func _on_enemy_defeated(points: int) -> void:
	current_points += points
	score.text = "Current score: " + str(current_points)
