class_name Hero
extends AnimatedSprite


var hitpoints = 100

signal attack_hit(damage)


func _ready():
	$Hitpoints.text = "HP: %s" %  [hitpoints]
	$Attack.text = ""


func _process(delta):
	pass


func _on_Monster_attack_hit(damage):
	hitpoints -= damage
	$Hitpoints.text = "HP: %s" %  [hitpoints]


func _on_Roller_roll_started():
	$Attack.text = ""


func _on_Roller_roll_determined(results):
	var damage = 0
	for result in results:
		damage += result
	emit_signal("attack_hit", damage)
	$Attack.text = "Slash! (%s DMG)" % [damage]
