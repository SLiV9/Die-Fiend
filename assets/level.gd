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
	update_probabilities()


func _process(_delta):
	update_probabilities()


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


func pop_item_in_room(i):
	var bbox = room_bbox(i)
	var targets = []
	for child in get_children():
		if child is Gem or child is Shard:
			if bbox.has_point(child.position):
				targets.append(child)
	if targets.size() > 0:
		targets.shuffle()
		var item = targets.pop_front()
		if item is Shard:
			var pop = $ResourcePreloader.get_resource("Pop").instance()
			pop.position = item.position
			pop.modulate = item.get_node("AnimatedSprite").modulate
			add_child(pop)
			item.queue_free()
			spawn_shard_in_room(5 - i)
		elif item is Gem and (rand_range(0, 100) < 16.67):
			var rock = $ResourcePreloader.get_resource("Rock").instance()
			rock.position = item.position
			add_child(rock)
			item.queue_free()


func room_bbox(i):
	var rooms = [$Room1, $Room2, $Room3, $Room4, $Room5, $Room6]
	var room = rooms[i]
	var center = room.position
	var bbox = Rect2(center.x - 16 * ROOM_SIZE / 2,
		center.y - 16 * ROOM_SIZE / 2,
		16 * ROOM_SIZE,
		16 * ROOM_SIZE)
	return bbox


func _on_Gremlin_shard_consumed():
	var best_i = randi() % 6
	for i in range(0, 6):
		if room_bbox(i).has_point($Gremlin.position):
			best_i = 5 - i
	self.call_deferred("spawn_shard_in_room", best_i)


func _on_Gremlin_gem_deposited():
	var gem = $ResourcePreloader.get_resource("Gem").instance()
	gem.position = $Gremlin.position
	for i in range(0, 6):
		if room_bbox(i).has_point($Gremlin.position):
			gem.get_node("AnimatedSprite").modulate = room_colors[i]
	add_child(gem)
	$SpacePrompt.visible = false


func determine_weights():
	var weights = [0, 0, 0, 0, 0, 0]
	for child in get_children():
		if child is Shard or child is Gem:
			for i in range(0, 6):
				if room_bbox(i).has_point(child.position):
					if child is Gem:
						weights[i] += 4
					elif child is Shard:
						weights[i] += 1
	return weights


func _on_Roller_rolled():
	var weights = determine_weights()
	$Hero/Roller.roll(weights)

func _on_MonsterRoller_rolled():
	var weights = [0, 0, 0, 0, 0, 0]
	if $Monster.is_hexed():
		# Only roll twos.
		weights[1] = 2
	$Monster/MonsterRoller.roll(weights)


func _on_Roller_roll_determined(results):
	for result in results:
		pop_item_in_room(result - 1)


func update_probabilities():
	var weights = determine_weights()
	var total_weight = 0
	for w in weights:
		total_weight += w
	var bbcode = ""
	for i in range(0, 6):
		var die = 1 + i
		var probability = 16.67
		if total_weight > 0:
			probability = round(1000 * weights[i] / total_weight) / 10
		bbcode = "%s\n{%s}: %s%%" % [bbcode, die, probability]
	bbcode = bbcode.replace("{1}", "[img]res://assets/dice_icons/dice_colored1.png[/img]")
	bbcode = bbcode.replace("{2}", "[img]res://assets/dice_icons/dice_colored2.png[/img]")
	bbcode = bbcode.replace("{3}", "[img]res://assets/dice_icons/dice_colored3.png[/img]")
	bbcode = bbcode.replace("{4}", "[img]res://assets/dice_icons/dice_colored4.png[/img]")
	bbcode = bbcode.replace("{5}", "[img]res://assets/dice_icons/dice_colored5.png[/img]")
	bbcode = bbcode.replace("{6}", "[img]res://assets/dice_icons/dice_colored6.png[/img]")
	$Probabilities.bbcode_text = bbcode


func _on_Gremlin_hunger_satiated():
	$SpacePrompt.visible = true
