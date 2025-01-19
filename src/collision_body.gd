extends RigidBody3D

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("pausable")

func _on_body_entered(body):
	if body.is_in_group("moving_wall"):
		print("Rozpoczęto kolizję ze ścianą")

func _on_body_exited(body):
	if body.is_in_group("moving_wall"):
		print("Zakończono kolizję ze ścianą")
