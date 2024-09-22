extends Area2D
class_name BaitDrop

@export var bait: BaitData = preload("res://scenes/items/maggot.tres")

func init(_bait: BaitData):
	bait = _bait

func _on_body_entered(body):
	if body is PlayerBoat:
		body.add_to_inventory(bait)
		call_deferred("queue_free")
