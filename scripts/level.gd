extends Node2D

const INITAL_BALL_SPEED = 400

func _determine_new_ball_velocity(body, ball) -> Vector2:
	
	# :HACK: Using the editor description of nodes to do control flow is 
	# extremely jank. Find a better way to determine if the body being collied 
	# with is a wall or not paddel. if there is some functionality to determine
	# which type a node is this will be sufficent.
	if(body.get_editor_description() == "Wall"):
		# The new angle of the ball is the same as the previous angle but in the
		# opposite direction. This is equlivant to fliping the signage on the y 
		# value in the vector
		#                             in        ^ out
		#                              \       /
		#                               \     /
		#                                \   /
		#                      Angle A     *      Angle A
		#      -----------------------------------------------------------
		
		var result = ball.get_linear_velocity()
		result.y *= -1
		return result
		
	else:
		# The new angle of the ball is not detemrined by the previous angular 
		# velocity when the player hits the ball. It is entierly based off of 
		# the offeset between the ball and the paddle
		#
		#                         ^ <- New vector (-1/sqrt(2), -1/sqrt(2)) * SPEED
		#                          \  ______
		#                           \ |    |
		#  Centre of ball    ->      *|    | <- Lets say that the ball is at (-1,-1)
		#                             |\   |
		#                             |  * | <- Centre of paddle (0,0) for example
		#                             |    |
		#                             |    |
		#                             |    |
		#                             ------
		# :TODO: Probably should rethink this approach, seems a bit too 
		# sensitive. Consider breaking up the paddle into 3 regions with 
		# predefined linear velocity vectors to apply to the ball on hit.
		
		assert(body.get_editor_description() == "Paddle")
		var centre_of_puck = body.get_global_position()
		var centre_of_ball = $Ball.get_global_position()
		print("paddle: " + str(centre_of_puck) + 
			  " \nball: " + str(centre_of_ball) + "\n")
			
		# Determine the y difference and calulate a normalised vector from the 
		# result.
		var difference_vector = centre_of_ball - centre_of_puck
		var result = difference_vector.normalized() * INITAL_BALL_SPEED
		print("new ball velocity: " + str(result) + "\n")
		return result
		
func _ready():
	
	# Santity check: Ensure that both Paddles are the same size.
	assert($PlayerPuck/CollisionShape2D.shape.get_rect().size == 
		   $OpponentPuck/CollisionShape2D.shape.get_rect().size)
	
	# :NOTE: Perhaps this would be better if a signal to change the ball speed 
	# was done instead of setting it directly here. Seems to work though 
	# currently.
	$Ball.set_linear_velocity(Vector2(INITAL_BALL_SPEED, 0.0))

func _on_ball_body_entered(body):
	print("Inital ball velocity: " + str($Ball.get_linear_velocity()) + "\n")
	$Ball.set_linear_velocity(_determine_new_ball_velocity(body, $Ball))
