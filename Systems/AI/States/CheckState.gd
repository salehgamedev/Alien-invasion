class_name CheckState
extends state


@onready var flee: FleeState = $"../FleeState"
@onready var wander: WanderState = $"../WanderState"
var player: PlayerShip
var alien: Alien
var _safe: bool = true
var _reaction_timer: float


func enter() -> void:
	alien.is_idle = true
	alien.facing_player = true
	_reaction_timer = alien.reaction_time
	if alien.position.distance_to(player.position) < alien.sight_distance and alien.is_player_visible:
		_safe = false
	else:
		_safe = true

func process(_delta: float) -> state:
	if _reaction_timer > 0:
		_reaction_timer -= _delta
		return null
	if _safe:
		return wander
	alien.show_suprise()
	return flee

func physics(_delta: float) -> state:
	alien.velocity = alien.velocity.move_toward(Vector2.ZERO, alien.deccel * _delta)
	return null

func exit() -> void:
	alien.facing_player = false
