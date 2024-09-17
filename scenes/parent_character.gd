class_name BaseCharacter extends CharacterBody2D


const SPEED = 66.0
var can_move: bool = true
var is_attacking: bool = false
var can_attack: bool = true
var is_attacked: bool = false
var is_dead: bool = false

enum Direction { LEFT, RIGHT, UP, DOWN }
var facing_direction = Direction.DOWN

var idle_animations = {
	Direction.LEFT: "idle_left",
	Direction.RIGHT: "idle_right",
	Direction.UP: "idle_up",
	Direction.DOWN: "idle_down"
}

var run_animations = {
	Direction.LEFT: "run_left",
	Direction.RIGHT: "run_right",
	Direction.UP: "run_up",
	Direction.DOWN: "run_down"
}

var attack_animations = {
	Direction.LEFT: "attack_left",
	Direction.RIGHT: "attack_right",
	Direction.UP: "attack_up",
	Direction.DOWN: "attack_down"
}

@export var max_health: int
var current_health: int

@onready var attack_cooldown: Timer = $AttackCooldown

signal health_changed

func _ready() -> void:
	SignalManager.character_damaged.connect(_on_character_damaged)
	health_changed.connect(on_health_changed)
	$Healthbar.set_health(100)
	current_health = max_health
	
	
func _on_character_damaged(character: Node2D, damage: int) -> void:
	if character == self and current_health > 0:
		is_attacked = true
		apply_damage(damage)


func apply_damage(damage: int):
	print(current_health)
	current_health -= damage
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		is_dead = true
		SignalManager.enemy_defeated.emit(10)
		$AnimatedSprite2D.play("death")
		$CorpseTimer.start()  # Start the timer to remove the enemy after death
	else:
		if !is_attacking:
			$AnimatedSprite2D.play("hurt")	

func on_health_changed(current_health: int, max_health: int):
	$Healthbar.set_health(current_health)
	
# Function to handle movement, to be called from child classes
func handle_movement(input_direction: Vector2, delta: float):
	velocity = input_direction * SPEED

	if input_direction != Vector2.ZERO and not is_attacking:
		facing_direction = get_direction_from_input(input_direction)
		if can_move:
			move_and_slide()

# Determine direction based on input
func get_direction_from_input(input_direction: Vector2) -> Direction:
	input_direction = input_direction.normalized()

	if abs(input_direction.x) > abs(input_direction.y):
		if input_direction.x < 0:
			return Direction.LEFT
		else:
			return Direction.RIGHT
	else:
		if input_direction.y < 0:
			return Direction.UP
		else:
			return Direction.DOWN

# Play animations based on the facing direction
func play_animation(animation_dict: Dictionary) -> void:
	var anim = animation_dict.get(facing_direction, "idle_down")
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)

# Handle attack cooldown timeout
func _on_attack_cooldown_timeout() -> void:
	can_attack = true

# Handle animation finished
func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		can_move = true
