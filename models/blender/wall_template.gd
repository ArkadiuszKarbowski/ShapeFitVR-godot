extends Node3D

@export var speed: float = 2.0
@export var move_direction: Vector3 = Vector3(0, 0, 1)
@export var score_threshold: Vector3 = Vector3(0, 0, 1)

@onready var wall_body = $sciana_wycieta 
@onready var score = get_node("/root/world/score")

var flag : bool = false
var velocity = move_direction * speed


func _physics_process(delta):
	if !is_instance_valid(wall_body):
		return
	

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
