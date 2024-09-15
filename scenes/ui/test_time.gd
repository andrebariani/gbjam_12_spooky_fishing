extends Label


func _physics_process(delta):
	WorldTime._run(delta)
	
	self.text = "%02d:%02d" % [WorldTime.hours, WorldTime.minutes] 
