extends Node2D

const rebound = 20

func _ready() -> void:
	randomize()
	var body_colour = Color(randf(), randf(), randf())
	$Anchor/SlimeBody.modulate = body_colour.lightened(0.6)
	$Anchor/Face/SlimeFace.modulate = body_colour.lightened(0.9)
	
func play_walk():
	%AnimationPlayer.play("walk")


func play_hurt():
	%AnimationPlayer.play("hurt")
	%AnimationPlayer.queue("walk")
