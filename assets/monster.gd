class_name Monster
extends AnimatedSprite


var hitpoints = 40
var attack_damage = 5

var respawn_delay = 0

signal attack_hit(damage)
signal attack_missed()


func _ready():
	$Hitpoints.text = "HP: %s" %  [hitpoints]
	$Attack.text = ""


func _process(delta):
	if respawn_delay > 0:
		respawn_delay -= delta
		if respawn_delay < 0:
			hitpoints = 40
			$Hitpoints.text = "HP: %s" %  [hitpoints]
			attack_damage += 3
			$MonsterRoller.reset()
			$MonsterRoller.visible = true


func _on_MonsterRoller_roll_determined(results):
	if hitpoints < 0:
		return
	var num_hits = 0
	for result in results:
		if result == 6:
			num_hits += 1
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


func _on_Hero_hero_died():
	pass
