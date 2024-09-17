extends BaseCharacter

const ATTACK_RANGE = 300.0
@onready var healthbar: TextureProgressBar = $Healthbar
@onready var attack_range: Area2D = $AttackRange
@onready var pulsate_timer: Timer = $PulsateTimer

var player_in_range: Node2D = null
var bodies_nearby: Array[Node2D]

var player: Node2D = null

func _ready() -> void:
	SignalManager.character_damaged.connect(_on_character_damaged)
	health_changed.connect(on_health_changed)
	$Healthbar.set_health(100)
	current_health = max_health
	player = get_node("../Player")  # Adjust the path based on where your Player node is located in the scene

func _process(delta: float) -> void:
	if is_dead or is_attacked or is_attacking:
		return  # Skip movement if the enemy is dead, being attacked, or attacking
		
	# If the player is in range and can attack, start the attack
	if is_player_in_attack_area() and can_attack:
		print("in the area")
		start_attack_player(player_in_range)
	else:
		# If no player is in range, check if the player is still close enough to move toward
		if is_player_in_range():
			move_toward_player(delta)
		else:
			$AnimatedSprite2D.play("idle")

# Start the attack, but don't interrupt it once started
func start_attack_player(player: Node2D) -> void:
	can_attack = false
	can_move = false
	is_attacking = true
	$AnimatedSprite2D.play("attack")

	# Use a timer or wait for animation finished signal
	$AttackTimer.start()  # Set a timer for attack cooldown/reset
	
func is_player_in_attack_area() -> bool:
	bodies_nearby = attack_range.get_overlapping_bodies()
	player_in_range = null
	
	var player_found: bool = false
	
	for body in bodies_nearby:
		if body.is_in_group("player"):
			print("hurray")
			return true
			break
			
	return player_found

# Function to check if the player is within a specific range for chasing
func is_player_in_range() -> bool:
	var distance_to_player = position.distance_to(player.position)
	return distance_to_player <= ATTACK_RANGE

# Function to move the enemy toward the player
func move_toward_player(delta: float) -> void:
	var direction_to_player = (player.position - position).normalized()
	velocity = direction_to_player * SPEED
	move_and_slide()

	# Play movement animation (for example, "walk" animation)
	$AnimatedSprite2D.play("walk")


# Handle attack animation finished event
func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacked:
		is_attacked = false
	if is_attacking:
		# When the attack animation finishes, reset the attack state
		is_attacking = false
		can_move = true
		can_attack = true

func _on_attack_timer_timeout() -> void:
	is_attacking = false
	can_move = true
	can_attack = true

func _on_animated_sprite_2d_frame_changed() -> void:
	# Check if the current animation is "attack"
	if $AnimatedSprite2D.animation == "attack":
		# Freeze on the second frame (index 1, since it starts from 0)
		if $AnimatedSprite2D.frame == 1:  
			$AnimatedSprite2D.stop()  # Freeze the animation
			start_pulsating_effect()
			
# Start the pulsating effect (pulsating red color for 1 second)
func start_pulsating_effect():
	pulsate_timer.start(1.0)  # Pulsate for 1 second
	modulate = Color(1, 0, 0)  # Set initial red color



func _on_pulsate_timer_timeout() -> void:
	modulate = Color(1, 1, 1)  # Reset color back to normal
	pulsate_timer.stop()  # Stop the pulsating timer
	var current_progress = $AnimatedSprite2D.get_frame_progress()
	$AnimatedSprite2D.set_frame_and_progress(3, current_progress)
	$AnimatedSprite2D.play()
	if is_player_in_attack_area():
		print("wtf")
		SignalManager.character_damaged.emit(player, 10)


func _on_corpse_timer_timeout() -> void:
	queue_free()
