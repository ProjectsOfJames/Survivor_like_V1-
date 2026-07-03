extends CharacterBody2D

var mob_health = {
	"slime": 3,
}

var mob_type
var rebound = 20

@onready var player = get_node("/root/Game/Player")

func _ready() -> void:
	%Slime.play_walk()
	mob_type = "slime"

func _physics_process(_delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300.0
	move_and_slide()

func take_damage():
	mob_health[mob_type] -= 1
	%Slime.play_hurt()
	
	if mob_health[mob_type] == 0:
		queue_free()
		
		const SMOKE_EXPLOSION = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE_EXPLOSION.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
		
