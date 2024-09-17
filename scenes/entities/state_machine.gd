@tool
class_name StateMachine
extends Node

var states = {}
var entity = null
var state_curr = null
var state_next = null
var state_last = null
var node_state

func init(_entity, initial_state := "Idle") -> void:
	self.entity = _entity
	var state_nodes = get_children()
	for state_node in state_nodes:
		add_state(state_node)
	
	change_state(initial_state)


func run(_delta) -> void:
	if node_state:
		node_state.run(_delta)


func change_state(new_state: String) -> void:
	if !states.has(new_state) or new_state == state_curr:
		return
	state_next = new_state
	if state_next != state_curr:
		state_last = state_curr
		state_curr = state_next
		node_state = states[state_curr]
		node_state._begin()
	
	if entity.has_method("setup_state_queue"):
		entity.setup_state_queue(state_next)


func add_state(state: State) -> void:
	self.states[state.name] = state
	state.stateMachine = self
	state.entity = self.entity
	state.initialize()


func remove_state(state: State) -> void:
	self.states.erase(state.name)


func has_state(s : String) -> bool:
	return states.has(s)

func get_state(s : String) -> State:
	return states[s]

func get_current_state() -> State:
	if state_curr == null:
		return states["Idle"]
	return states[state_curr]

func end_current_state(next_state : String) -> void:
	get_current_state().end(next_state)


func _get_configuration_warnings():
	if get_children():
		for n in get_children():
			if n is State:
				return ""

	return "At least one State child is required"
