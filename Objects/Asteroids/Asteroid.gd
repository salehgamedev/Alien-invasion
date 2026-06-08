class_name Asteroid
extends StaticBody2D


var health: int = 1
const SPEED_BOOSTER: PackedScene = preload("uid://ykqedo0gaqaa")

func take_damage(damage: int, booster_angle: float = PI/2) -> void:
	health -= damage
	
	if health <= 0:
		die(booster_angle)

func die(booster_angle: float) -> void:
	if randf() > 0.5:
		var speed_booster = SPEED_BOOSTER.instantiate()
		speed_booster.rotation = booster_angle
		speed_booster.position = position
		get_parent().call_deferred("add_child", speed_booster)
		process_mode = Node.PROCESS_MODE_DISABLED
	
	call_deferred("queue_free")
