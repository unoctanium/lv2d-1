# =========================================
# character_state_machine.gd
# =========================================
extends Node2D
class_name CharacterStateMachine

var current_state: CharacterState = null
var states := {}
var character: CharacterBase = null

func initialize(character_base: CharacterBase):
	character = character_base
	for child in get_children():
		if child is CharacterState:
			states[child.name] = child
			child.character = character
	
	# Start in your spawn state
	switch_state("SpawnState")
	
func _ready():
	pass
	
func switch_state(state_name: String):
	if current_state:
		current_state.exit()
	
	var next_state = states.get(state_name, null)
	if not next_state:
		push_error("StateMachine: no state named '%s'" % state_name)
		character.label.text = "error: " + state_name 
		return
	
	current_state = next_state
	character.label.text = state_name

	current_state.enter()

func physics_update(delta):
	if current_state:
		current_state.physics_update(delta)

func handle_input(event):
	if current_state:
		current_state.handle_input(event)

