extends Node3D

@export var base_speed: float = 4.0
@export var move_direction: Vector3 = Vector3(0, 0, 1)
@export var score_threshold: Vector3 = Vector3(0, 0, 1)
@export var min_speed_multiplier: float = 0.5
@export var max_speed_multiplier: float = 2.0
@export var normal_speed_multiplier: float = 1.0

# Distance thresholds in meters
@export var close_threshold: float = 0.5
@export var normal_threshold: float = 1.0
@export var wide_threshold: float = 2.0

@onready var wall_body = $sciana_wycieta 
@onready var score = get_node("/root/world/score")
@onready var right_controller = get_node("/root/world/player/XROrigin3D/XRController3D_rightH")
@onready var left_controller = get_node("/root/world/player/XROrigin3D/XRController3D_leftH")

var flag : bool = false
var current_speed: float = base_speed
var velocity = move_direction * current_speed

func _physics_process(delta):
	if !is_instance_valid(wall_body) or !is_instance_valid(right_controller) or !is_instance_valid(left_controller):
		return
	
	var arm_spread = right_controller.global_position.distance_to(left_controller.global_position)
	var speed_multiplier = normal_speed_multiplier
	
	# Determine speed zone based on arm spread
	if arm_spread <= close_threshold:
		speed_multiplier = max_speed_multiplier
	elif arm_spread <= normal_threshold:
		speed_multiplier = normal_speed_multiplier
	else:
		speed_multiplier = min_speed_multiplier
	
	# Update velocity
	current_speed = base_speed * speed_multiplier
	velocity = move_direction * current_speed
	
	print("Arm spread: %.2f m, Zone: %s, Speed: %.2f" % 
		[arm_spread, 
		"FAST" if speed_multiplier == max_speed_multiplier 
		else "NORMAL" if speed_multiplier == normal_speed_multiplier 
		else "SLOW", 
		current_speed])
	
	if wall_body:
		wall_body.linear_velocity = velocity
		if wall_body.global_transform.origin.z > score_threshold.z and !flag:
			flag = true
			_on_score_threshold_crossed(wall_body)


func _ready():
	add_to_group("pausable")
	add_to_group("moving_wall")
	if wall_body:
		wall_body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		wall_body.contact_monitor = true
		wall_body.max_contacts_reported = 4
		wall_body.body_entered.connect(_on_body_entered)
		wall_body.lock_rotation = true
		wall_body.gravity_scale = 0.0


func _on_body_entered(body):
	if body is RigidBody3D:
		print("Kolizja z: ", body.name)
		get_node("/root/world").show_game_over()		
		
func _on_score_threshold_crossed(body: RigidBody3D):
	if score:
		score.add_points(10) 
	print("Ciało przekroczyło próg. Usuwam ciało:", body.name)
	body.queue_free() 
