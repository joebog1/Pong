extends Node2D

const INITAL_BALL_SPEED = 400

# Function takes the current ball position and OpponentPaddle and returns a 
# normalised vector representing direction the OpponentPaddle should move in.
# This is expected to be a vector with y movement only.
# In the case the OpponentPaddle is perfectly lined up with the ball, (0,0) is 
# returned.
func determine_movement_direction():
	# Take the current y positions of the Ball and OpponentPaddle
	var resulting_direction: Vector2 =                                         \
	Vector2(0,                                                                 \
			$Ball.get_global_position().y >                                    \
			$OpponentPaddle.get_global_position().y)
	
	assert(resulting_direction.x == 0)
	# Since x is always 0 and the length must add up to 1 then y must be either 
	# -1 or 1 or 0 in the case of the ball being perfectly lined up with the 
	# paddle
	assert(abs(resulting_direction.y) == 1 || resulting_direction.y == 0)
	
	return resulting_direction


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
		
		# :BUG: move_and_slide() changes the linear velocity when a collision 
		# occurs. What we really want is 
		# ball.get_last_slide_collision().get_collider_velocity() but ball has 
		# "lost" is knwolwedge of that as it was passed in as a Node2d, not as a
		# CharacterBody2D. This means currently the behaviour is trash
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
	assert($PlayerPaddle/CollisionShape2D.shape.get_rect().size == 
		   $OpponentPaddle/CollisionShape2D.shape.get_rect().size)
	
	# :NOTE: Perhaps this would be better if a signal to change the ball speed 
	# was done instead of setting it directly here. Seems to work though 
	# currently.
	$Ball.set_linear_velocity(Vector2(INITAL_BALL_SPEED, 0.0))

func _process(delta):
	# Determine the direction OpponentPaddle should move in.
	var new_direction = determine_movement_direction()
	
	# :TODO: Should this be done with signals? hard to determine what is "right"
	# in this context at the moment.
	$OpponentPaddle.apply_movement(new_direction)
	
func _on_ball_body_entered(body):
	print("Inital ball velocity: " + str($Ball.get_linear_velocity()) + "\n")
	$Ball.set_linear_velocity(_determine_new_ball_velocity(body, $Ball))

