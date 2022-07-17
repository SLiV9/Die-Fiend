class_name Hero
extends AnimatedSprite


const NUM_HEROES = 8
const NAMES = ["Krem the Adventurer", "Borf the Woodsman", "Yonka the Barbarian",
	"Talis the Baneslayer", "Ilama the Tracker", "Atticus the Knight",
	"Ogovan the Mage", "Serbo the Warlock"]
const CURSES = ["Oops!", "Drat!", "Curses!", "Nope.", "Argh!", "Yikes.",
	"Welp."]

var hitpoints = 100
var hex_number = 2

signal attack_hit(a, b)
signal spell_hit(a)
signal hex_hit()
signal hero_died()


func _ready():
	randomize()
	frame = randi() % NUM_HEROES
	$Name.text = NAMES[frame]
	$Hitpoints.text = "HP: %s" %  [hitpoints]
	$Attack.text = ""


func _process(delta):
	pass


func _on_Monster_attack_hit(damage):
	hitpoints -= damage
	if hitpoints > 0:
		$Hitpoints.text = "HP: %s" %  [hitpoints]
	else:
		$Hitpoints.text = "HERO SLAIN"
		$Attack.text = ""
		$Roller.visible = false
		emit_signal("hero_died")


func _on_Roller_roll_started():
	$Attack.text = ""


func _on_Roller_roll_determined(results):
	if hitpoints <= 0:
		return
	var num_sixes = 0
	var a
	var b
	var num_hexes = 0
	for result in results:
		if result == 6:
			num_sixes += 1
		else:
			if a == null:
				a = result
			elif b == null:
				b = result
			if result == hex_number:
				num_hexes += 1
	if num_sixes == 3:
		emit_signal("attack_hit", 6, 6)
	elif num_sixes == 2:
		emit_signal("attack_hit", 6, a)
	elif num_sixes == 1:
		emit_signal("attack_hit", a, b)
	elif num_hexes == 2:
		emit_signal("hex_hit")
		hex_number += 1
		if hex_number >= 6:
			hex_number = 2
	elif results == [a, a, a] and a >= 3:
		emit_signal("spell_hit", a)
	else:
		var curse_offset = randi() % CURSES.size()
		$Attack.text = '"%s" (NO EFFECT)' % [CURSES[curse_offset]]


func _on_Monster_monster_died():
	pass


func _on_Monster_hero_attack_resolved(text):
	$Attack.text = text


func _on_Monster_hero_healed(amount):
	if hitpoints <= 0:
		return
	hitpoints += amount
	$Hitpoints.text = "HP: %s" %  [hitpoints]
