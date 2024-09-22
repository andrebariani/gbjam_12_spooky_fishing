extends Area2D

@onready var shape: CollisionShape2D = $DetectShape

var shadow: Shadow = null
var bait = null

func init(entity: Shadow):
	shadow = entity

func can_see_bait():
	if bait != null and bait.bait == shadow.fish.bait:
		
		var ray: RayCast2D = shadow.lineOfSight
		
		var bait_pos = bait.global_position
		
		ray.target_position = bait_pos
		
		# print_debug(ray.target_position)
		
		if not ray.is_colliding():
			return true
	
	return false

func _on_body_entered(_body):
	# print_debug('somethin here')
	bait = _body

func _on_body_exited(_body):
	# print_debug('bye')
	bait = null


func _on_area_entered(_area):
	bait = _area


func _on_area_exited(_area):
	bait = null
