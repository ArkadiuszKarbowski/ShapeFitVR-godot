extends Node3D

@export var spawn_interval_min: float = 1.0
@export var spawn_interval_max: float = 3.0
@export var max_concurrent_objects: int = 5
@export var script_path: String = "res://models/wall.gd"

var object_script: Script
var spawn_timer: float = 0.0
var current_objects: Array = []
var possible_objects: Array[PackedScene] = []

func _ready():
	object_script = load(script_path)
	for child in get_children():
		if child is Node3D:
			var scene_path = child.scene_file_path
			if scene_path:
				var packed_scene = load(scene_path)
				if packed_scene:
					possible_objects.append(packed_scene)
					child.queue_free()
	
	randomize()
	spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)

func _process(delta):
	spawn_timer -= delta
	
	if spawn_timer <= 0:
		spawn_object()
		spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)
	
	current_objects = current_objects.filter(func(obj): return is_instance_valid(obj))

func spawn_object():
	if current_objects.size() >= max_concurrent_objects or possible_objects.is_empty():
		return
		
	var scene = possible_objects.pick_random()
	var instance = scene.instantiate()
	
	if object_script:
		instance.set_script(object_script)
	
	instance.position = Vector3(0, -1, -16)
	var rotation_y = PI/2 if randi() % 2 == 0 else -PI/2
	instance.rotation.y = rotation_y
	
	get_parent().add_child(instance)
	current_objects.append(instance)
