extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var box_scale: float = 0.075
onready var box = load("res://box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var rects = []
	var ss = Vector2(0, 0)
	for i in range(OS.get_screen_count()):
		var size = OS.get_screen_size(i) + OS.get_screen_position(i)
		ss.x = max(ss.x, size.x)
		ss.y = max(ss.y, size.y)
	var w = ss.x / min(ss.x, ss.y)
	var h = ss.y / min(ss.x, ss.y)
	var sw = w / max(w, h)
	var sh = h / max(w, h)
	# Iterate again, now that we have ss
	for i in range(OS.get_screen_count()):
		var pos = OS.get_screen_position(i)
		var size = OS.get_screen_size(i)
		rects.append(PoolVector2Array([
			Vector2(((pos.x + 250         ) / ss.x) * w, ((pos.y + 250         ) / ss.y) * h),
			Vector2(((pos.x + size.x + 250) / ss.x) * w, ((pos.y + 250         ) / ss.y) * h),
			Vector2(((pos.x + size.x + 250) / ss.x) * w, ((pos.y + size.y + 250) / ss.y) * h),
			Vector2(((pos.x + 250         ) / ss.x) * w, ((pos.y + size.y + 250) / ss.y) * h)
			]))
	var bbox = PoolVector2Array([
						Vector2(0                        , 0                        ),
						Vector2(((ss.x + 500) / ss.x) * w, 0                        ),
						Vector2(((ss.x + 500) / ss.x) * w, ((ss.y + 500) / ss.y) * h),
						Vector2(0                        , ((ss.y + 500) / ss.y) * h),
						Vector2(0                        , 0.00001                  ),
						Vector2(((ss.x + 499) / ss.x) * w, ((ss.y + 499) / ss.y) * h)
						])
	var clip = bbox
	for rect in rects:
		clip = Geometry.clip_polygons_2d(clip, rect)
		clip = clip[0]
	var clip_tris = Geometry.triangulate_polygon(clip)
	var tris = []
	var tri = []
	for point in clip_tris:
		if len(tri) <3: # accidental heart :D
			var pt = clip[point] * 10
			tri.append(pt)
		else:
			print(tri)
			tris.append(tri)
			tri = [clip[point] * 10]
	tris.append(tri)
	for triangle in tris:
		var bound = CollisionPolygon.new()
		bound.polygon = triangle
		bound.translation = Vector3(((ss.x + 500) / ss.x) * -w/2, ((ss.y + 500) / ss.y) * h/2, 0) * 10
		bound.rotation_degrees = Vector3(180, 0, 0)
		bound.margin = 0.005
		$MonitorBounds.add_child(bound, true)
	$Area/CollisionShape.shape.set("extents", Vector3(w * 5, h * 5, 1))
	OS.set_window_size(ss)
	OS.window_borderless = true
	OS.set_window_position(Vector2(0, 0))
	OS.set_window_always_on_top(true)
	OS.set_window_per_pixel_transparency_enabled(true)
	get_tree().get_root().set_transparent_background(true)
	var t_scale = min(w, h) * box_scale
	var size = Vector3(t_scale, t_scale, t_scale) * 10
	$Box.set_size(size)
	$Box.translation = Vector3(0, 0, -0.25)

func _process(delta):
	var tf = $Box/Mesh.get_global_transform()
	var points = PoolVector2Array()
	for p in $Box/Mesh.mesh.get_faces():
		points.push_back($Camera.unproject_position(tf.xform(p)))
	var shape = ConvexPolygonShape2D.new()
	shape.set_point_cloud(points)
	var m_pos = get_viewport().get_mouse_position()
	OS.set_window_mouse_passthrough(PoolVector2Array(shape.points))
