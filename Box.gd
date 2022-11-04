extends RigidBody
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var s = Vector3.ONE

# Called when the node enters the scene tree for the first time.
func set_size(size):
	$BoxCollision.shape.set("extents", size)
	$Mesh.scale = size
	s = size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		self.gravity_scale = 0
		var toy_pos = self.global_translation
		var mouse_pos = get_node("/root/Space/Camera").project_position(get_viewport().get_mouse_position(), 5.25)
		print(toy_pos, mouse_pos)
		self.add_force((mouse_pos - toy_pos), Vector3.ZERO)
	else:
		self.gravity_scale = s.length() * 2
