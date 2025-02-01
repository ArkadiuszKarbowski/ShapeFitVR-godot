extends Node3D

@export var spawn_interval_min: float = 2.0
@export var spawn_interval_max: float = 3.0
@export var max_concurrent_objects: int = 10
@export var script_path: String = "res://models/wall.gd"

var object_script: Script
var spawn_timer: float = 0.0
var current_objects: Array = []
var template_objects: Array[Node3D] = []

func _ready():
	print("Ready called")
	object_script = load(script_path)
	for child in get_children():
		if child is Node3D:
			print("Found child: ", child.name)
			child.visible = false
			template_objects.append(child)
	
	print("Template objects: ", template_objects.size())
	randomize()
	spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)

func _process(delta):
	spawn_timer -= delta
	
	if spawn_timer <= 0:
		print("Spawning object")
		spawn_object()
		spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)

func spawn_object():
	if current_objects.size() >= max_concurrent_objects or template_objects.is_empty():
		print("Cannot spawn: ", current_objects.size(), " ", template_objects.is_empty())
		return
		
	var template = template_objects.pick_random()
	var instance = template.duplicate()
	instance.visible = true
	
	for child in instance.get_children():
		if child is MeshInstance3D:
			child.scale = Vector3(1,1,2)
			
	if object_script:
		instance.set_script(object_script)
	
	instance.position = Vector3(0, -1, -16)
	var rotation_y = PI/2 if randi() % 2 == 0 else -PI/2
	instance.rotation.y = rotation_y
	
	get_parent().add_child(instance)
	current_objects.append(instance)
