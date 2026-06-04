class_name Asteroid
extends Node

var health: int:
	set(value):
		_health = max(value, 0)
	get:
		return _health
var _health: int = 1

func take_damage(damage: int) -> void:
	health -= damage
	
	if health == 0:
		die()

func die() -> void:
	call_deferred("queue_free")
