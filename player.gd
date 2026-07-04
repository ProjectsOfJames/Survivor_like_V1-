extends CharacterBody2D
signal health_depleted

var health = 100.0

func _physics_process(delta: float) -> void:
	# Movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 600
	move_and_slide()
	
	if velocity.length() > 0.0: 
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()
		
	if direction.x < 0:
		%HappyBoo.scale.x = -1
	else: 
		%HappyBoo.scale.x = 1
	
	# Damage Calculations
	const DAMAGE_RATE = 5.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0: 
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		if health <= 0.0:
			health_depleted.emit()
