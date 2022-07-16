extends KinematicBody2D

var movement_delay = 0
var momentum = 0

func _ready():
	pass


func _process(delta):
	if movement_delay > 0:
		movement_delay -= delta
	if momentum > 0:
		momentum -= delta
	if movement_delay <= 0:
		var movement = Vector2(0, 0)
		if Input.is_action_pressed("move_left"):
			movement.x = -16
		elif Input.is_action_pressed("move_right"):
			movement.x = 16
		elif Input.is_action_pressed("move_up"):
			movement.y = -16
		elif Input.is_action_pressed("move_down"):
			movement.y = 16
		if movement.length() > 0:
			var space = get_world_2d().get_direct_space_state()
			if not space.intersect_point(self.position + movement, 1, [], 1):
				self.position += movement
			if momentum > 0.100:
				movement_delay = 0.070
			elif momentum > 0:
				movement_delay = 0.100
			else:
				movement_delay = 0.250
			momentum = 0.300
