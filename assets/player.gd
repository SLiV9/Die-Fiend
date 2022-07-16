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
			if not space.intersect_point(self.position + movement, 1, [], mask):
				if is_depositing:
					emit_signal("gem_deposited")
					is_depositing = false
					num_shards_consumed = 0
					$AnimatedSprite.animation = "idle"
				self.position += movement
			if momentum > 0.100:
				movement_delay = 0.070
			elif momentum > 0:
				movement_delay = 0.100
			else:
				movement_delay = 0.250
			momentum = 0.300


func _on_Area2D_body_entered(body):
	if body is StaticBody2D:
		body.queue_free()
		emit_signal("shard_consumed")
		num_shards_consumed += 1
		if num_shards_consumed >= NUM_SHARDS_NEEDED:
			$AnimatedSprite.animation = "jumping"
