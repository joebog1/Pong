extends Node2D

const INITAL_BALL_SPEED = 400

func _determine_new_ball_velocity(body):
	# The new angle of the ball is not detemrined by the previous angular 
	# velocity. It is entierly based off of the offeset between the ball and 
	# the puck
	#
	#                         ^ <- New angle
	#                          \  ______
	#                           \ |    |
	#  Centre of ball    ->      *|    |
	#                             |\   |
	#                             |  * | <- Centre of puck
	#                             |    |
	#                             |    |
	#                             |    |
	#                             ------
	
	var centre_of_puck = body.get_global_position()
	
	var centre_of_ball = $Ball.get_global_position()
	print("puck: " + str(centre_of_puck) + 
		  " \nball: " + str(centre_of_ball) + "\n")
	# Determine the y difference and calulate a normalised vector from the 
	# result.
	var difference_vector = centre_of_ball - centre_of_puck
	var result = difference_vector.normalized() * INITAL_BALL_SPEED
	print("result: " + str(result) + "\n")
	return result

func _ready():
	
	# Santity check: Ensure that both pucks are the same size.
	assert($PlayerPuck/CollisionShape2D.shape.get_rect().size == 
		   $OpponentPuck/CollisionShape2D.shape.get_rect().size)
	
	# :NOTE: Perhaps this would be better if a signal to change the ball speed 
	# was done instead of setting it directly here. Seems to work though 
	# currently.
	$Ball.set_linear_velocity(Vector2(INITAL_BALL_SPEED, 0.0))

func _on_ball_body_entered(body):
	# :TODO: Do maths here to determine the new body velocity.
	print(str($Ball.get_linear_velocity()))
	$Ball.set_linear_velocity(_determine_new_ball_velocity(body))
