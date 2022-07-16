class_name Hero
extends AnimatedSprite


const HEAL_FROM_KILL = 10

var hitpoints = 100

signal attack_hit(damage)
signal hero_died()


func _ready():
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
	var damage = 0
	for result in results:
		damage += result
	emit_signal("attack_hit", damage)
	$Attack.text = "Slash! (%s DMG)" % [damage]


func _on_Monster_monster_died():
	if hitpoints > 0:
		hitpoints += HEAL_FROM_KILL
		$Hitpoints.text = "HP: %s" %  [hitpoints]
