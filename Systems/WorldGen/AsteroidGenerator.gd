class_name AsteroidGenerator
extends Node

@export_category("configurations")
@export var chunk_size: int = 128
@export var render_distance: int = 6
@export var large_asteroid_rarity: float = 0.5
@export var small_asteroid_rarity: float = 0.2
@export_category("refrences")
@export var ASTEROID_S: PackedScene
@export var ASTEROID_M: PackedScene
@export var player: PlayerShip
var world_seed: int = randi()
var rand_noise := FastNoiseLite.new()
var generated_chunks: PackedVector2Array = [Vector2(1, 0)]
enum AstroidSize {small, medium}


func _ready() -> void:
	rand_noise.seed = world_seed

func _process(_delta: float) -> void:
	var chunk_position = Vector2i(player.position/chunk_size)
	
	for x in range(chunk_position.x-render_distance, chunk_position.x+render_distance):
		for y in range(chunk_position.y-render_distance, chunk_position.y+render_distance):
			if not Vector2(x, y) in generated_chunks:
				_generate_chunk(Vector2i(x, y))
				generated_chunks.append(Vector2(x, y))

func _generate_chunk(chunk_pos: Vector2i):
	for x in range(chunk_pos.x*chunk_size, (chunk_pos.x+1)*chunk_size, 64):
		for y in range(chunk_pos.y*chunk_size, (chunk_pos.y+1)*chunk_size, 64):
			if rand_noise.get_noise_2d(x, y) > large_asteroid_rarity:
				_spawn_asteroid(Vector2i(x, y), AstroidSize.medium)
			elif rand_noise.get_noise_2d(x, y) > small_asteroid_rarity:
				_spawn_asteroid(Vector2i(x, y), AstroidSize.small)

func _spawn_asteroid(position: Vector2i, size: AstroidSize = AstroidSize.small) -> void:
	var asteroid: Asteroid
	if size == AstroidSize.small:
		asteroid = ASTEROID_S.instantiate()
	elif size == AstroidSize.medium:
		asteroid = ASTEROID_M.instantiate()
	
	var scale = randf_range(0.8, 1.5)
	asteroid.scale = Vector2(scale, scale)
	asteroid.rotation_degrees = randi_range(0, 3) * 90
	asteroid.position = position+Vector2i(randi_range(0, 32), randi_range(0, 32))
	get_parent().call_deferred("add_child", asteroid)
