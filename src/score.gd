extends Label3D

var score : int = 0
var tween: Tween

func add_points(points: int) -> void:
	score += points
	text = "Score: " + str(score)
