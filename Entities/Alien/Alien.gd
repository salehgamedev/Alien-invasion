class_name Alien
extends CharacterBody2D

@export_category("refrences")
@export var state_manager: StateManager
@export var animation: AnimatedSprite2D
@export var surprise: Sprite2D
@export var alien_ray_cast: RayCast2D
@export var asteroid_ray_cast: RayCast2D
@export var player_ray_cast: RayCast2D
@export_category("stats")
@export var sight_distance: int = 240
@export var reaction_time: float = 0.5
@export var fleeing_distance: int = 120
@export var max_speed: float = 85
@export var deccel: float = 60
@export var accel: float = 100
@export var turning_speed: float = 2.0
@export var max_health: int = 1
var speed: float:
	get:
		return velocity.length()
var gonna_collide: bool:
	get:
		return alien_ray_cast.is_colliding() or asteroid_ray_cast.is_colliding()
var gonna_crash: bool:
	get:
		return asteroid_ray_cast.is_colliding()
var is_player_visible: bool:
	get:
		return not player_ray_cast.is_colliding()
var player: PlayerShip
var _fade_tween: Tween
var direction: Vector2 = Vector2(0, -1)
var facing_player: bool = false
var is_idle: bool = true
var health: int = max_health:
	set(value):
		health = value
		if health <= 0: die()

func _ready() -> void:
	player = get_parent().find_child("Ship", false)
	for _state in state_manager.get_children():
		_state.alien = self
		_state.player = player
	
	state_manager.current_state.enter()

func _physics_process(_delta: float) -> void:
	velocity = velocity.limit_length(max_speed)
	move_and_slide()

func _process(_delta: float) -> void:
	_manage_animation()
	_manage_raycasts_target_pos(_delta)

func _manage_raycasts_target_pos(delta: float) -> void:
	var raycast_target_pos = (speed*speed*direction)/(2*deccel)
	raycast_target_pos += raycast_target_pos.normalized() * (speed + (accel*delta) + 10)
	alien_ray_cast.target_position = raycast_target_pos
	asteroid_ray_cast.target_position = raycast_target_pos
	player_ray_cast.target_position = player.global_position - global_position

func _manage_animation() -> void:
	var facing_direction: String
	if facing_player:
		facing_direction = _get_facing_player_direction()
	else:
		facing_direction = _get_movement_direction()
	
	if is_idle:
		animation.play(facing_direction+"_idle")
	else:
		animation.play(facing_direction+"_flying")

func _get_movement_direction() -> String:
	if sign(direction.y) == -1:
		return "back"
	return "front"

func _get_facing_player_direction() -> String:
	var local_position = player.global_position - global_position
	if sign(local_position.y) == 1:
		return "front"
	return "back"

func show_suprise():
	surprise.visible = true
	surprise.modulate.a = 1
	if _fade_tween:
		_fade_tween.kill()
		
	_fade_tween = get_tree().create_tween()
	_fade_tween.tween_property(
		surprise,
		"modulate:a",
		0.0,
		2.0
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func take_damage(damage: int) -> void:
	health -= damage

func die():
	call_deferred("queue_free")
