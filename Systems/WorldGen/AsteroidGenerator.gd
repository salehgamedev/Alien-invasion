class_name AsteroidGenerator
extends Node

@export_category("configurations")
@export var chunk_size: int = 128
@export_category("refrences")
@export var PSAsteroidS: PackedScene
@export var PSAsteroidM: PackedScene
@export var player: PlayerShip
var world_seed: int = randi()
var rand_noise := FastNoiseLite.new()
var generated_chunks: PackedVector2Array = [Vector2(1, 0)]
enum AstroidSize {small, medium}


func _ready() -> void:
	rand_noise.seed = world_seed

func _process(_delta: float) -> void:
	var chunk_position = Vector2i(player.position/chunk_size)
	
	for x in range(chunk_position.x-3, chunk_position.x+3):
		for y in range(chunk_position.y-3, chunk_position.y+3):
			if not Vector2(x, y) in generated_chunks:
				_generate_chunk(Vector2i(x, y))
				generated_chunks.append(Vector2(x, y))

func _generate_chunk(chunk_pos: Vector2i):
	for x in range(chunk_pos.x*chunk_size, (chunk_pos.x+1)*chunk_size, 64):
		for y in range(chunk_pos.y*chunk_size, (chunk_pos.y+1)*chunk_size, 64):
			if rand_noise.get_noise_2d(x, y) > 0.5:
				_spawn_asteroid(Vector2i(x+randi_range(0, 32), y+randi_range(0, 32)), AstroidSize.medium)
			elif rand_noise.get_noise_2d(x, y) > 0.2:
				_spawn_asteroid(Vector2i(x+randi_range(0, 32), y+randi_range(0, 32)), AstroidSize.small)

func _spawn_asteroid(position: Vector2i, size: AstroidSize = AstroidSize.small) -> void:
	var asteroid: Asteroid
	if size == AstroidSize.small:
		asteroid = PSAsteroidS.instantiate()
	elif size == AstroidSize.medium:
		asteroid = PSAsteroidM.instantiate()
	
	var scale = randf_range(0.8, 1.5)
	asteroid.scale = Vector2(scale, scale)
	asteroid.rotation_degrees = randi_range(0, 3) * 90
	asteroid.position = position
	add_child(asteroid)
