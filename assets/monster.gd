class_name Monster
extends AnimatedSprite

const NUM_MONSTERS = 22
const NAMES = ["Rodent", "Spiders", "Slimes", "Big Beetle", "Zombie", "Slime Head", "Bat",
	"Giant Centipede", "Wyvern", "Giant Spider", "Goblin", "Snake", "Skeleton", "Giant Bat",
	"Orc", "Giant Scorpion", "Ogre", "Horror", "Cyclops", "Beholder", "Golem", "Demon"]
const HITPOINTS = [20, 30, 30, 40, 60, 40, 20,
	30, 30, 30, 50, 40, 60, 40,
	60, 40, 80, 70, 80, 60, 100, 90]
const ATTACK_DAMAGE = [1, 1, 2, 3, 4, 3, 2,
	2, 10, 3, 6, 5, 6, 5,
	6, 10, 8, 13, 18, 6, 32, 20]
const ATTACK_DELAYS = [3, 1, 3, 3, 5, 3, 3,
	1, 3, 1, 3, 3, 3, 3,
	3, 3, 5, 5, 5, 3, 10, 3]
const WEAKSPOTS = [3, 3, -1, 5, 2, -1, 3,
	3, 4, 3, 5, 4, 2, 3,
	5, -1, 3, -1, 1, -1, -1, -1]
const VULNERABILITIES = [[], [4], [], [], [4], [], [],
	[4], [3], [4], [3], [], [2], [],
	[], [], [], [], [], [], [], []]
const FULL_IMMUNITIES = [[], [], [], [], [], [], [6],
	[], [], [], [], [], [], [6],
	[], [], [], [1,6], [], [], [], [3,4,5]]
const SPELL_IMMUNITIES = [[], [], [], [], [3], [], [],
	[], [4], [], [], [3,4,5], [], [],
	[], [], [], [], [], [5], [], []]

var monster_offset = 0
var hitpoints = 40
var attack_damage = 5
var attack_delay = 3
var weakspot_number = 3
var vulnerabilities = []
var full_immunities = []
var spell_immunities = []

var respawn_delay = 0
var hex_end_delay = 0

signal attack_hit(damage)
signal hero_attack_resolved(text)
signal hero_healed(amount)
signal monster_died()


func _ready():
	frame = monster_offset
	hitpoints = HITPOINTS[monster_offset]
	attack_damage = ATTACK_DAMAGE[monster_offset]
	weakspot_number = WEAKSPOTS[monster_offset]
	vulnerabilities = VULNERABILITIES[monster_offset]
	full_immunities = FULL_IMMUNITIES[monster_offset]
	spell_immunities = SPELL_IMMUNITIES[monster_offset]
	$Name.text = NAMES[monster_offset]
	$Hitpoints.text = "HP: %s" %  [hitpoints]
	$Attack.text = ""
	$Description.bbcode_text = build_description_bbcode()


func build_description_bbcode():
	var bbcode = "%s ATK" % [attack_damage]
	if attack_delay < 3:
		bbcode = "%s (FAST)" % [bbcode]
	elif attack_delay >= 10:
		bbcode = "%s (VERY SLOW)" % [bbcode]
	elif attack_delay >= 5:
		bbcode = "%s (SLOW)" % [bbcode]
	if NAMES[monster_offset] == "Snake":
		bbcode = "%s\n%s" % [bbcode, "Also crits with (1)(1)."]
	elif NAMES[monster_offset] == "Beholder":
		bbcode = "%s\n%s" % [bbcode, "Also hits with (1)'s."]
	elif NAMES[monster_offset] == "Cyclops":
		bbcode = "%s\n%s" % [bbcode, "Needs exactly one (1) to hit."]
	if full_immunities == [6]:
		bbcode = "%s\nImmune to {6} (except {6}{w}{w})." % [bbcode]
	elif full_immunities.size() > 0:
		var faces = PoolStringArray()
		for x in full_immunities:
			faces.append("{%s}" % [x])
		bbcode = "%s\nImmune to %s." % [bbcode, faces.join("/")]
	if spell_immunities.size() > 0:
		var faces = PoolStringArray()
		for x in spell_immunities:
			faces.append("{%s}{%s}{%s}" % [x, x, x])
		bbcode = "%s\nImmune to %s." % [bbcode, faces.join("/")]
	if vulnerabilities.size() > 0:
		var faces = PoolStringArray()
		for x in vulnerabilities:
			faces.append("{%s}" % [x])
		bbcode = "%s\nVulnerable to %s." % [bbcode, faces.join("/")]
	if weakspot_number >= 0:
		bbcode = "%s\n{w} = {%s}" % [bbcode, weakspot_number]
	else:
		bbcode = "%s\n{w} = {%s}" % [bbcode, 7]
	bbcode = bbcode.replace("(1)", "[img]res://assets/dice_icons/enemy_1.png[/img]")
	bbcode = bbcode.replace("{1}", "[img]res://assets/dice_icons/dice_colored1.png[/img]")
	bbcode = bbcode.replace("{2}", "[img]res://assets/dice_icons/dice_colored2.png[/img]")
	bbcode = bbcode.replace("{3}", "[img]res://assets/dice_icons/dice_colored3.png[/img]")
	bbcode = bbcode.replace("{4}", "[img]res://assets/dice_icons/dice_colored4.png[/img]")
	bbcode = bbcode.replace("{5}", "[img]res://assets/dice_icons/dice_colored5.png[/img]")
	bbcode = bbcode.replace("{6}", "[img]res://assets/dice_icons/dice_colored6.png[/img]")
	bbcode = bbcode.replace("{7}", "[img]res://assets/dice_icons/dice_colored7.png[/img]")
	bbcode = bbcode.replace("{w}", "[img]res://assets/dice_icons/dice_colored_skull.png[/img]")
	bbcode = bbcode.replace("{?}", "[img]res://assets/dice_icons/dice_colored_empty.png[/img]")
	return bbcode


func _process(delta):
	if respawn_delay > 0:
		respawn_delay -= delta
		if Input.is_action_pressed("__cheat_next_monster"):
			respawn_delay -= 1000
		if respawn_delay < 0:
			monster_offset += 1
			var is_super = false
			if monster_offset >= NUM_MONSTERS:
				monster_offset = randi() % NUM_MONSTERS
				is_super = true
			frame = monster_offset
			hitpoints = HITPOINTS[monster_offset]
			attack_damage = ATTACK_DAMAGE[monster_offset]
			attack_delay = ATTACK_DELAYS[monster_offset]
			weakspot_number = WEAKSPOTS[monster_offset]
			vulnerabilities = VULNERABILITIES[monster_offset]
			full_immunities = FULL_IMMUNITIES[monster_offset]
			spell_immunities = SPELL_IMMUNITIES[monster_offset]
			if is_super:
				hitpoints *= 10
				attack_damage *= 5
				$Name.text = "Super " + NAMES[monster_offset]
			else:
				$Name.text = NAMES[monster_offset]
			$Description.bbcode_text = build_description_bbcode()
			$Hitpoints.text = "HP: %s" %  [hitpoints]
			$MonsterRoller.reset(attack_delay)
			$MonsterRoller.visible = true
	elif hex_end_delay > 0:
		hex_end_delay -= delta
	elif Input.is_action_just_pressed("__cheat_next_monster"):
		hero_dealt_damage(1000)


func _on_MonsterRoller_roll_determined(results):
	if hitpoints < 0:
		return
	var num_hits = 0
	var num_snake_eyes = 0
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
			damage *= 3
			$Attack.text = "Super Crit!"
		elif num_hits >= 2:
			damage *= 2
			$Attack.text = "Crit!"
		else:
			$Attack.text = "Hit!"
		emit_signal("attack_hit", damage)
		if NAMES[monster_offset] == "Horror":
			$ScreamSfx.play()
		else:
			$BiteSfx.play()
	else:
		$Attack.text = "Miss!"
		$MissSfx.play()


func _on_MonsterRoller_roll_started():
	$Attack.text = ""


func _on_Hero_attack_hit(a, b):
	if a == 6 and b == 6 and not full_immunities.has(6):
		var damage = 15
		var text = "Stab! (%s DMG)" % [damage]
		emit_signal("hero_attack_resolved", text)
		hero_dealt_damage(damage)
	elif a == 6 and not full_immunities.has(6) and not full_immunities.has(b):
		var damage = 10
		var text = "Slash! (%s DMG)" % [damage]
		if vulnerabilities.has(b):
			damage *= 2
			text = "Powerful Slash! (%s DMG)" % [damage]
		emit_signal("hero_attack_resolved", text)
		if b == 2:
			emit_signal("hero_healed", 5)
		hero_dealt_damage(damage)
	elif a == b and a == weakspot_number:
		var bodypart = "Heart"
		match weakspot_number:
			1:
				bodypart = "Eye"
			2:
				bodypart = "Skull"
			3:
				bodypart = "Hide"
			4:
				bodypart = "Scales"
		var text = "Pierce the %s! (KILL)" % [bodypart]
		emit_signal("hero_attack_resolved", text)
		if a == 2 or b == 2:
			emit_signal("hero_healed", 5)
		hero_dealt_damage(1000)
	elif full_immunities.has(6):
		var text = "Miss! (IMMUNE)"
		emit_signal("hero_attack_resolved", text)
	elif full_immunities.has(a) or full_immunities.has(b):
		var text = "Miss! (IMMUNE)"
		emit_signal("hero_attack_resolved", text)
	else:
		var damage = a * b
		var text = "Hack! (%s DMG)" % [damage]
		if vulnerabilities.has(a) or vulnerabilities.has(b):
			damage = damage * 3 / 2
			text = "Powerful Hack! (%s DMG)" % [damage]
		emit_signal("hero_attack_resolved", text)
		if a == 2 or b == 2:
			emit_signal("hero_healed", 5)
		hero_dealt_damage(damage)


func hero_dealt_damage(damage):
	hitpoints -= damage
	if hitpoints > 0:
		$Hitpoints.text = "HP: %s" %  [hitpoints]
	elif respawn_delay > 0:
		pass
	else:
		$Hitpoints.text = "FOE SLAIN"
		$Attack.text = ""
		$MonsterRoller.visible = false
		respawn_delay = 2.0
		hex_end_delay = -1
		emit_signal("monster_died")
		$DeathSfx.play()


func _on_Hero_hero_died():
	pass


func _on_Hero_spell_hit(a):
	var damage
	var spell
	match a:
		3:
			damage = 15
			spell = "Cone of Cold"
		4:
			damage = 20
			spell = "Fireball"
		5:
			damage = 25
			spell = "Lighting Bolt"
	var text
	if full_immunities.has(a) or spell_immunities.has(a):
		text = "%s! (0 DMG, IMMUNE)" % [spell]
		emit_signal("hero_attack_resolved", text)
		return
	if vulnerabilities.has(a):
		damage *= 2
		text = "%s! (%s DMG, POWERFUL!)" % [spell, damage]
	else:
		text = "%s! (%s DMG)" % [spell, damage]
	emit_signal("hero_attack_resolved", text)
	hero_dealt_damage(damage)
	match a:
		3:
			$IceSfx.play()
		4:
			$FireballSfx.play()
		5:
			$LightningSfx.play()


func _on_Hero_hex_hit(a):
	if full_immunities.has(a):
		var text = "Miss! (IMMUNE)"
		emit_signal("hero_attack_resolved", text)
		return
	emit_signal("hero_attack_resolved", "Hex!")
	hex_end_delay = 20.0


func is_hexed():
	return hex_end_delay > 0
