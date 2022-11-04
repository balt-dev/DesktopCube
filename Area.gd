extends Area


onready var box = get_node("/root/Space/Box")

func _process(delta):
	if not overlaps_body(box):
		box.translation = Vector3(0, 0, -0.25)
		box.linear_velocity = Vector3(0, 0, 0)
