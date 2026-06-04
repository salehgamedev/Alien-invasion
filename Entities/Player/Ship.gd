class_name PlayerShip
extends CharacterBody2D

@export_category("configurations")
@export var turn_speed: float = 6.0
@export var ship_deccel: float = 40.0
@export var throttle_accel: float = 200.0
@export var idle_deccel: float = 40.0
@export var max_throttle_speed: float = 100.0
@export_category("refrences")
@export var ship_base: Sprite2D
@export var thruster_flames: AnimatedSprite2D
@export var laser: PackedScene
@export var collision_detector: Area2D

var is_speedboosting: bool = false
var ship_velocity: Vector2 = Vector2.ZERO
var throttle_velocity: Vector2:
	set(value):
		throttle_velocity = value.limit_length(max_throttle_speed)
var throttle_speed: float = 0:
	get:
		return throttle_velocity.length()
var throttle_direction: Vector2:
	get:
		return Vector2.from_angle(rotation-PI/2)
var turn_direction: float:
	get:
		return Input.get_axis("turn_left", "turn_right")

func _process(_delta: float) -> void:
	thruster_flames.visible = Input.is_action_pressed("accelerate")
	if (ship_velocity+throttle_velocity).length() > max_throttle_speed * 1.2:
		thruster_flames.play("blue_flames")
		thruster_flames.visible = true
	else:
		thruster_flames.play("red_flames")
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _physics_process(delta: float) -> void:
	rotation += turn_direction * turn_speed * delta
	
	if Input.is_action_pressed("accelerate"):
		throttle_velocity += throttle_accel * throttle_direction * delta
	else:
		throttle_velocity = throttle_velocity.move_toward(Vector2.ZERO, idle_deccel * delta)
	
	apply_speed_booster_boost(delta)
	ship_velocity = ship_velocity.move_toward(Vector2.ZERO, ship_deccel * delta)
	
	velocity = throttle_velocity + ship_velocity
	
	move_and_slide()

func shoot() -> void:
	var shot: Node2D = laser.instantiate()
	shot.position = $ShipBase/LeftMuzzle.global_position
	shot.rotation = rotation
	var shot1 = shot.duplicate()
	shot.position = $ShipBase/RightMuzzle.global_position
	shot.scale.x = -1
	var shot2 = shot.duplicate()
	get_parent().call_deferred("add_child", shot1)
	get_parent().call_deferred("add_child", shot2)

func apply_speed_booster_boost(delta: float) -> void:
	for area in collision_detector.get_overlapping_areas():
		if area.is_in_group("speed_booster"):
			ship_velocity += area.speed_boost * delta * area.direction

func _on_collison_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("speed_booster"):
		ship_velocity += area.speed_boost * 0.2 * area.direction
