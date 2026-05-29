class_name PlayerShip
extends CharacterBody2D

@export_category("configurations")
@export var turn_speed: float = 6.0
@export var throttle_accel: float = 200.0
@export var idle_deccel: float = 40.0
@export var max_throttle_speed: float = 100.0
@export_category("refrences")
@export var ship_base: Sprite2D
@export var thruster_flames: AnimatedSprite2D
@export var laser: PackedScene

var linear_accel: float = 0:
	get:
		if Input.is_action_pressed("accelerate"):
			return throttle_accel
		else:
			return -idle_deccel
var throttle_speed: float = 0:
	set(value):
		throttle_speed = clamp(value, 0, max_throttle_speed)
var throttle_direction: Vector2:
	get:
		return Vector2.from_angle(rotation-PI/2)
var turn_direction: float:
	get:
		return Input.get_axis("turn_left", "turn_right")

func _ready() -> void:
	thruster_flames.play("white ship")

func _process(_delta: float) -> void:
	thruster_flames.visible = linear_accel > 0
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _physics_process(delta: float) -> void:
	rotation += turn_direction * turn_speed * delta
	
	throttle_speed += linear_accel * delta
	velocity = throttle_speed * throttle_direction
	
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
