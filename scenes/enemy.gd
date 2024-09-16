extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const ATTACK_RANGE = 300.0  # The distance within which the enemy will start moving toward the player
var is_dead: bool = false
var max_health: int = 30
var current_health: int = max_health
var is_attacked: bool = false
var player: Node2D  # Reference to the player
@onready var healthbar: TextureProgressBar = $Healthbar
signal health_changed  # Signal to notify health changes

func _ready() -> void:
	SignalManager.enemy_damaged.connect(_on_enemy_damaged)
	player = get_node("../Player")  # Adjust the path based on where your Player node is located in the scene
	health_changed.connect(on_health_changed)

func _process(delta: float) -> void:
	if is_dead or is_attacked:
		return  # Skip movement if the enemy is dead or being attacked

	# Check if the player is within the attack range
	if is_player_in_range():
		move_toward_player(delta)
	else:
		$AnimatedSprite2D.play("idle")

# Function to check if the player is within range
func is_player_in_range() -> bool:
	var distance_to_player = position.distance_to(player.position)
	return distance_to_player <= ATTACK_RANGE

# Function to move the enemy toward the player
func move_toward_player(delta: float) -> void:
	var direction_to_player = (player.position - position).normalized()
	velocity = direction_to_player * SPEED
	move_and_slide()

	# Play movement animation (for example, "run" animation)
	$AnimatedSprite2D.play("walk")

# Function to handle damage
func _on_enemy_damaged(enemy: Node2D, damage: int):
	if enemy == self:
		is_attacked = true
		apply_damage(damage)

func apply_damage(damage: int):
	current_health -= damage
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		is_dead = true
		$AnimatedSprite2D.play("death")
		$CorpseTimer.start()  # Start the timer to remove the enemy after death
	else:
		$AnimatedSprite2D.play("hurt")

func _on_corpse_timer_timeout() -> void:
	queue_free()  # Remove the enemy from the game

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacked:
		is_attacked = false

func on_health_changed(current_health: int, max_health: int):
	healthbar.set_health(current_health)
	
