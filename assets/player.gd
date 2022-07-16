extends KinematicBody2D

const NUM_SHARDS_NEEDED = 5

var num_shards_consumed = 0
var is_depositing = false

var movement_delay = 0
var momentum = 0

signal shard_consumed()
signal gem_deposited()


func _ready():
	pass


func _process(delta):
	if num_shards_consumed >= NUM_SHARDS_NEEDED and not is_depositing:
		if Input.is_action_pressed("drop_item"):
			is_depositing = true
	if movement_delay > 0:
		movement_delay -= delta
	if momentum > 0:
		momentum -= delta
	if movement_delay <= 0:
		var at_left = self.position + Vector2(-16, 0)
		var at_right = self.position + Vector2(16, 0)
		var at_up = self.position + Vector2(0, -16)
		var at_down = self.position + Vector2(0, 16)
		var space = get_world_2d().get_direct_space_state()
		var mask = 1
		if num_shards_consumed >= NUM_SHARDS_NEEDED:
			mask |= 2
		var at
		if (Input.is_action_pressed("move_left")
				and not space.intersect_point(at_left, 1, [], mask)):
			at = at_left
			self.scale.x = -1
		elif (Input.is_action_pressed("move_right")
				and not space.intersect_point(at_right, 1, [], mask)):
			at = at_right
			self.scale.x = 1
		elif (Input.is_action_pressed("move_up")
				and not space.intersect_point(at_up, 1, [], mask)):
			at = at_up
		elif (Input.is_action_pressed("move_down")
				and not space.intersect_point(at_down, 1, [], mask)):
			at = at_down
		if at:
			if is_depositing:
				emit_signal("gem_deposited")
				is_depositing = false
				num_shards_consumed = 0
				$AnimatedSprite.animation = "idle"
			self.position = at
			if momentum > 0.100:
				movement_delay = 0.080
			elif momentum > 0:
				movement_delay = 0.100
			else:
				movement_delay = 0.250
			momentum = 0.300
		else:
			movement_delay = 0.050


func _on_Area2D_body_entered(body):
	if body is StaticBody2D:
		body.queue_free()
		emit_signal("shard_consumed")
		num_shards_consumed += 1
		if num_shards_consumed >= NUM_SHARDS_NEEDED:
			$AnimatedSprite.animation = "jumping"
