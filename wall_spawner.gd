extends Node3D

# Export variables to customize spawning in the Godot Inspector
@export var object_scene: PackedScene  # The scene to spawn
@export var spawn_area_size: Vector3 = Vector3(5, 2, 1)  # Area where objects can spawn
@export var spawn_interval_min: float = 1.0  # Minimum time between spawns
@export var spawn_interval_max: float = 3.0  # Maximum time between spawns
@export var max_concurrent_objects: int = 5  # Maximum number of objects at once
@export var possible_objects: Array[PackedScene] = []

# Speed and direction parameters
@export var min_speed: float = 1.0
@export var max_speed: float = 4.0
@export var move_direction: Vector3 = Vector3(0, 0, 1)

# Internal tracking variables
var spawn_timer: float = 0.0
var current_objects: Array = []

func _ready():
	# Randomize the spawn timer
	randomize()
	spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)

func _process(delta):
	# Decrement spawn timer
	spawn_timer -= delta
	
	# Check if it's time to spawn a new object
	if spawn_timer <= 0:
		spawn_object()
		# Reset spawn timer with a random interval
		spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)
	
	# Clean up any destroyed objects from the tracking array
	current_objects = current_objects.filter(func(obj): return is_instance_valid(obj))

func spawn_object():
	# Check if we've reached the maximum number of concurrent objects
	if current_objects.size() >= max_concurrent_objects:
		return
	
	# Instantiate the object scene
	if not object_scene:
		push_error("No object scene assigned to spawner!")
		return
	
	var new_object = object_scene.instantiate()
	
	# Calculate random spawn position within the spawn area
	var spawn_position = Vector3(
		global_position.x + randf_range(-spawn_area_size.x/2, spawn_area_size.x/2),
		global_position.y + randf_range(-spawn_area_size.y/2, spawn_area_size.y/2),
		global_position.z
	)
	
	# Set the object's position
	new_object.global_transform.origin = spawn_position
	
	# Configure movement (similar to your existing script)
	var speed = randf_range(min_speed, max_speed)
	var velocity = move_direction * speed
	
	# If the spawned object has a wall_body (based on your existing script)
	if new_object.has_method("set_velocity"):
		new_object.set_velocity(velocity)
	elif new_object.get("wall_body"):
		new_object.wall_body.linear_velocity = velocity
	
	# Add to scene and tracking array
	add_child(new_object)
	current_objects.append(new_object)

# Optional function to clear all spawned objects
func clear_all_objects():
	for obj in current_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	current_objects.clear()

# Optional function to pause/unpause spawning
func set_spawning_enabled(enabled: bool):
	set_process(enabled)
