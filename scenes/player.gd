extends BaseCharacter

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
			SignalManager.character_damaged.emit(body, 10)

	attack_cooldown.start()
