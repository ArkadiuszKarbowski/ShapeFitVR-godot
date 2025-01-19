extends XRCamera3D  

var mouse_sensitivity: float = 0.3
var camera_rotation: Vector2 = Vector2.ZERO  

func _ready() -> void:
	if not get_viewport().use_xr:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	
	if not get_viewport().use_xr and event is InputEventMouseMotion:
		camera_rotation.x -= event.relative.y * mouse_sensitivity
		camera_rotation.y -= event.relative.x * mouse_sensitivity
		
		
		camera_rotation.x = clamp(camera_rotation.x, -90, 90)

		rotation_degrees = Vector3(camera_rotation.x, camera_rotation.y, 0)

func _process(delta: float) -> void:
	if not get_viewport().use_xr:
		pass
