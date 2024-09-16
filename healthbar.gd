extends TextureProgressBar

# HealthBar script to handle health updates

# Initialize max and current health
@export var max_health: int
var current_health: int = max_health

# Function to set health and update the progress bar
func set_health(value: int):
	current_health = clamp(value, 0, max_health)
	self.value = (current_health * 100) / max_health

# Reset the health bar to full
func reset_health():
	set_health(max_health)

# Check if the entity is dead (0 health)
func is_dead() -> bool:
	return current_health <= 0
