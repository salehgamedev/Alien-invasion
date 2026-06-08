class_name FleeState
extends state


@onready var check: CheckState = $"../CheckState"
@onready var time_till_relaxed: Timer = $TimeTillRelaxed
var player: PlayerShip
var alien: Alien
var asteroid_ahead: Asteroid:
	get:
		return alien.asteroid_ray_cast.get_collider()
var previous_asteroid: Asteroid
var dodge_direction: int = 0

func enter() -> void:
	alien.direction = (alien.global_position - player.global_position).normalized()
	
	alien.is_idle = false
	time_till_relaxed.wait_time = randf_range(3.5, 4.5)
	time_till_relaxed.start()

func process(_delta: float) -> state:
	if not alien.gonna_crash:
		previous_asteroid = null
		return null
	if asteroid_ahead != previous_asteroid:
		previous_asteroid = asteroid_ahead
		var collision_normal = alien.asteroid_ray_cast.get_collision_normal()
		dodge_direction = _get_closest_tangent(alien.direction, collision_normal)
		_rotate_alien_towards(dodge_direction, _delta)
		return null
	_rotate_alien_towards(dodge_direction, _delta)
	return null

func _rotate_alien_towards(target_direction: int, delta: float) -> void:
	var rotation_amount = alien.turning_speed * delta * target_direction
	alien.direction = alien.direction.rotated(rotation_amount)

func _get_closest_tangent(referenced_vector: Vector2, normal: Vector2) -> int:
	var slope_dir1 = Vector2(normal.y, -normal.x)
	var slope_dir2 = Vector2(-normal.y, normal.x)
	
	var ref_angle = referenced_vector.angle()
	var tangent1_angle = slope_dir1.angle()
	var tangent2_angle = slope_dir2.angle()
	
	var diff1 = angle_difference(ref_angle, tangent1_angle)
	var diff2 = angle_difference(ref_angle, tangent2_angle)
	if abs(diff1) < abs(diff2):
		return sign(diff1)
	return sign(diff2)

func physics(_delta: float) -> state:
	alien.velocity = alien.velocity.move_toward(alien.max_speed*alien.direction, alien.accel * _delta)
	return null

func _on_time_till_relaxed_timeout() -> void:
	alien.state_manager.switch_state_to(check)

func exit() -> void:
	time_till_relaxed.stop()
