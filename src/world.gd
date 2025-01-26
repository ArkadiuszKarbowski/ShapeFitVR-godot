extends Node3D

@onready var xr_controller: XRController3D = $player/XROrigin3D/XRController3D_rightH
@onready var game_over_label: Label3D = null
var interface: XRInterface
var pausable_nodes: Array = []
var is_paused: bool = false  

func _ready() -> void:
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		get_viewport().use_xr = true
	
	xr_controller.button_pressed.connect(_on_button_pressed)
	if not xr_controller.has_signal("button_pressed"):
		print("WARNING: button_pressed signal not found on XR Controller!")
	
	game_over_label = Label3D.new()
	game_over_label.text = "GAME OVER\nClick right trigger to restart"
	game_over_label.font_size = 24
	game_over_label.modulate = Color.RED
	game_over_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	game_over_label.visible = false
	add_child(game_over_label)
	
	_find_pausable_nodes(self)
	#print("Znaleziono ", pausable_nodes.size(), " obiektów do pauzowania")
	#for node in pausable_nodes:
		#print("Obiekt do pauzowania: ", node.name)

func _find_pausable_nodes(node: Node):
	if node.is_in_group("pausable"):
		pausable_nodes.append(node)
	for child in node.get_children():
		_find_pausable_nodes(child)

func show_game_over():
	if is_paused: 
		return
		
	var camera = get_viewport().get_camera_3d()
	if camera:
		game_over_label.global_position = camera.global_position + (-camera.global_transform.basis.z * 2)
	game_over_label.visible = true
	
	print("Pauzowanie gry...")
	is_paused = true
	
	# Bezpośrednie zatrzymanie wszystkich RigidBody3D w scenie
	var physics_objects = get_tree().get_nodes_in_group("pausable")
	for node in physics_objects:
		print("Pauzowanie obiektu: ", node.name)
		if node is RigidBody3D:
			node.freeze = true
			node.linear_velocity = Vector3.ZERO
			node.angular_velocity = Vector3.ZERO
			# Dodatkowe zabezpieczenie
			node.set_physics_process(false)
			node.gravity_scale = 0
			
		if node is CharacterBody3D:
			node.set_physics_process(false)
			node.set_process(false)
			
		if node.has_method("set_physics_process"):
			node.set_physics_process(false)
		if node.has_method("set_process"):
			node.set_process(false)

func _on_button_pressed(button_name: String):
	if button_name == "trigger" and game_over_label.visible:
		restart_game()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_T:
				xr_controller.emit_signal("button_pressed", "trigger")
				print("button pressed")


func restart_game():
	is_paused = false  
	game_over_label.visible = false
	get_tree().reload_current_scene()
