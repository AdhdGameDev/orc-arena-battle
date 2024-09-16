extends CharacterBody2D

@onready var attack_cooldown: Timer = $AttackCooldown
const SPEED = 300.0
var can_move: bool = true
var is_attacking: bool = false
var can_attack: bool = true

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

func _ready() -> void:
	$Healthbar.set_health(100)

func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED

	if input_direction != Vector2.ZERO and not is_attacking:
		facing_direction = get_direction_from_input(input_direction)

	if Input.is_action_just_pressed("attack") and not is_attacking and can_attack:
		handle_attack()

	if not is_attacking:
		if input_direction == Vector2.ZERO:
			play_animation(idle_animations)
		else:
			play_animation(run_animations)

	if can_move:
		move_and_slide()

# New function to handle attacks
func handle_attack() -> void:
	can_attack = false
	can_move = false
	is_attacking = true
	play_animation(attack_animations)
	
	var bodies: Array[Node2D] = $AttackArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemy"):
			SignalManager.enemy_damaged.emit(body, 10)

	attack_cooldown.start()

# Determine direction from input
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

# Play the correct animation based on facing direction
func play_animation(animation_dict: Dictionary) -> void:
	var anim = animation_dict.get(facing_direction, "idle_down")
	if $AnimatedSprite2D.animation != anim:
		$AnimatedSprite2D.play(anim)

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		can_move = true

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
