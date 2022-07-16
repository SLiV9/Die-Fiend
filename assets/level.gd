extends Node2D

const ROOM_SIZE = 10


func _ready():
	#randomize()
	for room in [$Room1, $Room2, $Room3, $Room4, $Room5, $Room6]:
		spawn_shard_in_room(room)
		spawn_shard_in_room(room)
		spawn_shard_in_room(room)

func spawn_shard_in_room(room):
	var space = get_world_2d().get_direct_space_state()
	var mask = 1 | 2
	for _attempt in range(0, 100):
		var target = room.position
		target.x += 8 + 16 * ((randi() % ROOM_SIZE) - ROOM_SIZE / 2)
		target.y += 8 + 16 * ((randi() % ROOM_SIZE) - ROOM_SIZE / 2)
		if not space.intersect_point(target, 1, [], mask):
			var shard = $ResourcePreloader.get_resource("Shard").instance()
			shard.position = target
			add_child(shard)
			return


func _on_Gremlin_shard_consumed():
	var best_i = randi() % 6
	var rooms = [$Room1, $Room2, $Room3, $Room4, $Room5, $Room6]
	for i in range(0, 6):
		if rooms[i].overlaps_body($Gremlin):
			best_i = 5 - i
	self.call_deferred("spawn_shard_in_room", rooms[best_i])


func _on_Gremlin_gem_deposited():
	var gem = $ResourcePreloader.get_resource("Gem").instance()
	gem.position = $Gremlin.position
	add_child(gem)
