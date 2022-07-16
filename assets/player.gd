extends KinematicBody2D

const NUM_SHARDS_NEEDED = 5

var num_shards_consumed = 4

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
			self.scale.x = -1
		elif Input.is_action_pressed("move_right"):
			movement.x = 16
			self.scale.x = 1
		elif Input.is_action_pressed("move_up"):
			movement.y = -16
		elif Input.is_action_pressed("move_down"):
			movement.y = 16
		if movement.length() > 0:
			var space = get_world_2d().get_direct_space_state()
			var mask = 1
			if num_shards_consumed >= NUM_SHARDS_NEEDED:
				mask |= 2
			print(mask)
			if not space.intersect_point(self.position + movement, 1, [], mask):
				self.position += movement
			if momentum > 0.100:
				movement_delay = 0.070
			elif momentum > 0:
				movement_delay = 0.100
			else:
				movement_delay = 0.250
			momentum = 0.300


func _on_Area2D_body_entered(body):
	print(body.name)
	if body is StaticBody2D:
		body.queue_free()
		num_shards_consumed += 1
		if num_shards_consumed >= NUM_SHARDS_NEEDED:
			$AnimatedSprite.animation = "jumping"
