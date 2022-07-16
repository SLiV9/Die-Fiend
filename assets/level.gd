extends Node2D

const ROOM_SIZE = 10

export(Array, Color) var room_colors = []

func _ready():
	randomize()
	$Gremlin.room_colors = room_colors
	for i in range(0, 6):
		spawn_shard_in_room(i)
		spawn_shard_in_room(i)
		spawn_shard_in_room(i)


func spawn_shard_in_room(i):
	var rooms = [$Room1, $Room2, $Room3, $Room4, $Room5, $Room6]
	var room = rooms[i]
	var space = get_world_2d().get_direct_space_state()
	var mask = 1 | 2
	for _attempt in range(0, 100):
		var target = room.position
		target.x += 8 + 16 * ((randi() % ROOM_SIZE) - ROOM_SIZE / 2)
		target.y += 8 + 16 * ((randi() % ROOM_SIZE) - ROOM_SIZE / 2)
		if not space.intersect_point(target, 1, [], mask):
			var shard = $ResourcePreloader.get_resource("Shard").instance()
			shard.position = target
			shard.get_node("AnimatedSprite").modulate = room_colors[i]
			add_child(shard)
			return


func remove_item_in_room(i):
	var rooms = [$Room1, $Room2, $Room3, $Room4, $Room5, $Room6]
	var room = rooms[i]
	var bodies = room.get_overlapping_bodies()
	var targets = []
	for body in bodies:
		if body is Gem:
			targets.append(body)
		elif body is Shard:
			targets.append(body)
	if targets.size() > 0:
		targets.shuffle()
		var item = targets.pop_front()
		item.queue_free()


func _on_Gremlin_shard_consumed():
	var best_i = randi() % 6
	var rooms = [$Room1, $Room2, $Room3, $Room4, $Room5, $Room6]
	for i in range(0, 6):
		if rooms[i].overlaps_body($Gremlin):
			best_i = 5 - i
	self.call_deferred("spawn_shard_in_room", best_i)


func _on_Gremlin_gem_deposited():
	var gem = $ResourcePreloader.get_resource("Gem").instance()
	gem.position = $Gremlin.position
	var rooms = [$Room1, $Room2, $Room3, $Room4, $Room5, $Room6]
	for i in range(0, 6):
		if rooms[i].overlaps_body($Gremlin):
			gem.get_node("AnimatedSprite").modulate = room_colors[i]
	add_child(gem)


func _on_Roller_rolled():
	var weights = [0, 0, 0, 0, 0, 0]
	var rooms = [$Room1, $Room2, $Room3, $Room4, $Room5, $Room6]
	for i in range(0, 6):
		var bodies = rooms[i].get_overlapping_bodies()
		for body in bodies:
			if body is Gem:
				weights[i] += 4
			elif body is Shard:
				weights[i] += 1
	print(weights)
	for child in get_children():
		if child is Gem:
			print(child, child.collision_layer, child.collision_mask)
	$Hero/Roller.roll(weights)

func _on_MonsterRoller_rolled():
	$Monster/MonsterRoller.roll([0, 0, 0, 0, 0, 0])


func _on_Roller_roll_determined(results):
	for result in results:
		remove_item_in_room(result - 1)
		var opposite_face = 7 - result
		spawn_shard_in_room(opposite_face - 1)


func _on_Room1_body_entered(body):
	print(body, " entered")


func _on_Room1_body_exited(body):
	print(body, " exited")
