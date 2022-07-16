class_name Monster
extends AnimatedSprite

const NUM_MONSTERS = 22
const NAMES = ["Rodent", "Spiders", "Bat", "Slimes", "Big Beetle", "Slime Head", "Zombie",
	"Giant Centipede", "Wyvern", "Giant Spider", "Goblin", "Snake", "Skeleton", "Giant Bat",
	"Orc", "Giant Scorpion", "Ogre", "Horror", "Cyclops", "Beholder", "Golem", "Demon"]
const HITPOINTS = [20, 20, 20, 30, 40, 40, 60,
	30, 30, 40, 50, 40, 60, 40,
	60, 40, 80, 70, 80, 60, 100, 90]
const ATTACK_DAMAGE = [1, 3, 5, 3, 4, 4, 2,
	5, 10, 8, 6, 5, 6, 5,
	6, 10, 5, 8, 15, 6, 7, 20]

var monster_offset = 0
var hitpoints = 40
var attack_damage = 5

var respawn_delay = 0

signal attack_hit(damage)
signal attack_missed()
signal monster_died()


func _ready():
	hitpoints = HITPOINTS[monster_offset]
	attack_damage = ATTACK_DAMAGE[monster_offset]
	$Name.text = NAMES[monster_offset]
	$Hitpoints.text = "HP: %s" %  [hitpoints]
	$Attack.text = ""


func _process(delta):
	if respawn_delay > 0:
		respawn_delay -= delta
		if respawn_delay < 0:
			monster_offset += 1
			var is_super = false
			if monster_offset >= NUM_MONSTERS:
				monster_offset = randi() % NUM_MONSTERS
				is_super = true
			frame = monster_offset
			hitpoints = HITPOINTS[monster_offset]
			attack_damage = ATTACK_DAMAGE[monster_offset]
			if is_super:
				hitpoints *= 10
				attack_damage *= 5
				$Name.text = "Super " + NAMES[monster_offset]
			else:
				$Name.text = NAMES[monster_offset]
			$Hitpoints.text = "HP: %s" %  [hitpoints]
			$MonsterRoller.reset()
			$MonsterRoller.visible = true


func _on_MonsterRoller_roll_determined(results):
	if hitpoints < 0:
		return
	var num_hits = 0
	var num_snake_eyes = 0
	var blinded = false
	for result in results:
		if result == 6:
			num_hits += 1
		elif result == 1:
			num_snake_eyes += 1
	if NAMES[monster_offset] == "Snake":
		if num_snake_eyes == 2 and num_hits < 2:
			num_hits = 2
	elif NAMES[monster_offset] == "Beholder":
		if num_hits < num_snake_eyes:
			num_hits = num_snake_eyes
	elif NAMES[monster_offset] == "Cyclops":
		if num_snake_eyes != 1:
			num_hits = 0
	if num_hits > 0:
		var damage = attack_damage
		if num_hits >= 3:
			damage *= 10
			$Attack.text = "Super Crit!"
		elif num_hits >= 2:
			damage *= 2
			$Attack.text = "Crit!"
		else:
			$Attack.text = "Hit!"
		emit_signal("attack_hit", damage)
	else:
		emit_signal("attack_missed")
		$Attack.text = "Miss!"


func _on_MonsterRoller_roll_started():
	$Attack.text = ""


func _on_Hero_attack_hit(damage):
	hitpoints -= damage
	if hitpoints > 0:
		$Hitpoints.text = "HP: %s" %  [hitpoints]
	elif respawn_delay > 0:
		pass
	else:
		$Hitpoints.text = "FOE SLAIN"
		$Attack.text = ""
		$MonsterRoller.visible = false
		respawn_delay = 5.0
		emit_signal("monster_died")


func _on_Hero_hero_died():
	pass
