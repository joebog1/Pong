extends Node2D

# :TODO: Currently this design just shoves everything into the level node script
# because it's the only place that "knows" about the other nodes and thus can 
# communicate between them. This results in a bunch of potentially unrelated 
# code being shoved into one place. It'd be nice if there was a way I can split 
# this out into several files.

const INITAL_BALL_SPEED = 400

var previous_ball_velocity = Vector2(INITAL_BALL_SPEED, 0.0)

# :HACK: Should be const but we don't know the position till _ready is called.
# since we need it outside of the the scope of just _ready it is declared as a 
# var here.
var inital_ball_position = Vector2.ZERO

# Function takes the current ball position and OpponentPaddle and returns a 
# normalised vector representing direction the OpponentPaddle should move in.
# This is expected to be a vector with y movement only.
# In the case the OpponentPaddle is perfectly lined up with the ball, (0,0) is 
# returned.
func determine_movement_direction(ball, paddle):
	# Take the current y positions of the Ball and OpponentPaddle
	var ball_y_position = ball.get_global_position().y
	var paddle_y_position = paddle.get_global_position().y
	if(ball_y_position == paddle_y_position): return Vector2(0,0)
	
	var resulting_direction =                                                  \
	Vector2(0, 1 if ball_y_position > paddle_y_position else -1)
	
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
		
		previous_ball_velocity.y *= -1
		return previous_ball_velocity
		
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
		# sensitive on testing. Consider breaking up the paddle into 3 regions 
		# with predefined linear velocity vectors to apply to the ball on hit.
		
		assert(body.get_editor_description() == "Paddle")
		var centre_of_puck = body.get_global_position()
		var centre_of_ball = ball.get_global_position()
			
		# Determine the y difference and calulate a normalised vector from the 
		# result.
		var difference_vector = centre_of_ball - centre_of_puck
		var result = difference_vector.normalized() * INITAL_BALL_SPEED
		previous_ball_velocity = result
		return result
		
func _ready():
	
	# Santity check: Ensure that both Paddles are the same size.
	assert($PlayerPaddle/CollisionShape2D.shape.get_rect().size == 
		   $OpponentPaddle/CollisionShape2D.shape.get_rect().size)
	
	# :NOTE: Perhaps this would be better if a signal to change the ball speed 
	# was done instead of setting it directly here. Seems to work though 
	# currently.
	$Ball.set_linear_velocity(previous_ball_velocity)
	$Ball/Timer.one_shot = true
	inital_ball_position = $Ball.get_global_position()

func _process(_delta):
	# Determine the direction OpponentPaddle should move in.
	var new_direction = determine_movement_direction($Ball, $OpponentPaddle)
	# If the direction is 0 we don't need to do anything and return early.
	if(new_direction.length_squared() == 0):
		return
		
	# :TODO: Should this be done with signals? Hard to determine what is "right"
	# in this context at the moment. Consult a style guide.
	$OpponentPaddle.apply_movement(new_direction)
	
func _on_ball_body_entered(body):
	$Ball.set_linear_velocity(_determine_new_ball_velocity(body, $Ball))

# This function takes the previous ball collision velocity and generates a 
# new velocity based off of the x direction of the previous velocity.
func determine_new_ball_velocity():
	# :TODO: Perhaps we should rely on the caller of the function to know the 
	# velocity of the ball rather then using the ball's current velocity as a 
	# deciding factor. 
	if(previous_ball_velocity.x < 0):
		return Vector2(-INITAL_BALL_SPEED, 0)
	else:
		return Vector2(INITAL_BALL_SPEED, 0)

func reset_ball_state(new_velocity:Vector2):
	# :HACK: Calling set_global_position immidentally causes the ball to 
	# disappear for some reason. The old 0 second timer solves the issue. 
	# I shouldn't need to do this (setting it to 0.1 makes the ball appear 
	# faster??)
	$Ball/Timer.start(0)
	
	# We should ensure that the new ball speed is the same as the inital speed.
	assert(new_velocity.length() == INITAL_BALL_SPEED)
	
	# Velocity of the ball is determined by the direction it was moving at the 
	# time of reset.
	$Ball.set_linear_velocity(new_velocity)
	
# :TODO: The following slots have duplicated code. Find a way to collate them 
# into a base class which handles this automatically. 

# Updates the provided scoreboard with the provided new_score
func update_scoreboard(goal: Area2D, new_score):
	#:TODO: Find a way of updating the goal without relying on the level scene's
	# knowledge of the node from the context that this method was called.
	goal.get_node("Label").set_text(new_score)

func _on_opponent_goal_body_entered(_area):
	#:TODO: Find a way of updating the goal without relying on the level scene's
	# knowledge of the node from the context that this method was called.
	var old_score = $OpponentGoal/Label.get_text().to_int()
	update_scoreboard($OpponentGoal, str(old_score + 1))
	reset_ball_state(determine_new_ball_velocity())

func _on_player_goal_body_entered(_area):
	#:TODO: Find a way of updating the goal without relying on the level scene's
	# knowledge of the node from the context that this method was called.
	var old_score = $PlayerGoal/Label.get_text().to_int()
	update_scoreboard($PlayerGoal, str(old_score + 1))
	reset_ball_state(determine_new_ball_velocity())


func _on_timer_timeout():
	$Ball.set_global_position(inital_ball_position)
