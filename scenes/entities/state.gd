extends Node
class_name State

signal entered(state)

var stateMachine : StateMachine = null
@onready var entity

var initialized = false

func initialize():
	if !initialized:
		initialized = true
		init()

func init():
	pass

func _begin():
	entered.emit(self)
	begin()

func begin():
	# when state start
	pass

func run(_delta):
	pass

func before_end(_next_state):
	pass

func end(next_state: String):
	if !stateMachine.get_state(next_state).check_if_can_enter_this_state():
		return false
	
	if has_node("Timer"):
		$Timer.stop()
	
	before_end(next_state)
	
	# when state exit
	stateMachine.change_state(next_state)
	return true

func check_if_can_enter_this_state() -> bool:
	return true

func is_current_state() -> bool:
	return stateMachine.get_current_state() == self

func animation_finished(_anim_name):
	pass
