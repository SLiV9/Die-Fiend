class_name Monster
extends AnimatedSprite


var hitpoints = 100
var attack_damage = 5

signal attack_hit(damage)
signal attack_missed()


func _ready():
	$Hitpoints.text = "HP: %s" %  [hitpoints]
	$Attack.text = ""


func _process(delta):
	pass


func _on_MonsterRoller_roll_determined(results):
	var num_hits = 0
	for result in results:
		if result == 6:
			num_hits += 1
	if num_hits > 0:
		var damage = attack_damage
		var crit_multiplier
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
	$Hitpoints.text = "HP: %s" %  [hitpoints]
