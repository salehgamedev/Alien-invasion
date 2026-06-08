class_name hurtbox
extends Area2D


@export var host: Node2D

func _ready() -> void:
	area_entered.connect(_on_HurtBox_area_entered)

func _on_HurtBox_area_entered(area: Area2D) -> void:
	if area.is_in_group("hit_box"):
		host.take_damage(area.damage)
