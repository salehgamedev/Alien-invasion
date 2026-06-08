class_name WanderState
extends state


@onready var flee: FleeState = $"../FleeState"
@onready var time_moving: Timer = $TimeMoving
@onready var time_idling: Timer = $TimeIdling
var player: PlayerShip
var alien: Alien

func enter() -> void:
	alien.is_idle = true
	time_idling.wait_time = randf_range(0, 3)
	time_idling.start()

func process(_delta: float) -> state:
	if (player.position).distance_to(alien.position) < alien.fleeing_distance and alien.is_player_visible:
		return flee
	
	return null

func physics(_delta: float) -> state:
	if alien.gonna_collide or alien.is_idle:
		alien.velocity = alien.velocity.move_toward(Vector2.ZERO, alien.deccel * _delta)
	else:
		alien.velocity = alien.velocity.move_toward(alien.max_speed*alien.direction, alien.accel * _delta)
	return null

func exit() -> void:
	time_moving.stop()
	time_idling.stop()
	alien.show_suprise()

func _on_time_moving_timeout() -> void:
	alien.is_idle = true
	time_idling.wait_time = (alien.speed/ alien.deccel) + randf_range(0, 3)
	time_idling.start()

func _on_time_idling_timeout() -> void:
	alien.is_idle = false
	alien.direction = Vector2.from_angle(randf_range(0, 2*PI))
	time_moving.wait_time = randf_range(0.5, 2)
	time_moving.start()
