extends Node2D

const INITAL_BALL_SPEED = 400

func _ready():
	# :NOTE: Perhaps this would be better if a signal to change the ball speed 
	# was done instead of setting it directly here. Seems to work though 
	# currently.
	$Ball.set_linear_velocity(Vector2(INITAL_BALL_SPEED, 0.0))

func _on_ball_body_entered(body):
	# :TODO: Do maths here to determine the new body velocity.
	print(str($Ball.get_linear_velocity()))
	$Ball.set_linear_velocity(-$Ball.get_linear_velocity())
