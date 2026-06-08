class_name StateManager
extends Node

@export_category("states")
@export var wander: WanderState
@export var flee: FleeState
@export var check: CheckState
@export var current_state: state


func switch_state_to(new_state: state) -> void:
	if new_state == null:
		return
	
	if current_state != null:
		current_state.exit()
	current_state = new_state
	current_state.enter()

func _process(delta: float) -> void:
	if current_state != null:
		switch_state_to(current_state.process(delta))

func _physics_process(delta: float) -> void:
	if current_state != null:
		switch_state_to(current_state.physics(delta))

func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		switch_state_to(current_state.HandleInputs(event))
