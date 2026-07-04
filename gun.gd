extends Area2D


func _physics_process(delta: float) -> void:
	var enemies_in_range = get_overlapping_bodies();
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)
		
		var gun_rotation = $WeaponPivot.get_global_rotation_degrees()
		if gun_rotation > 90 or gun_rotation < -90 :
			$WeaponPivot/Pistol.flip_v = true
		else:
			$WeaponPivot/Pistol.flip_v = false

func shoot():
	const BULLET = preload("res://bullet.tscn")
	
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %ShootingPoint.global_position
	new_bullet.global_rotation = %ShootingPoint.global_rotation
	%ShootingPoint.add_child(new_bullet)


func _on_timer_timeout() -> void:
	shoot()
