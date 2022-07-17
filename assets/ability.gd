class_name Ability
extends AnimatedSprite

export var die1 = 6
export var die2 = -1
export var die3 = -1
export var description = ""

func _ready():
	$Die1.fix(die1)
	$Die2.fix(die2)
	$Die3.fix(die3)
	$Name.text = description


func _on_Hero_hex_hit(_a):
	die1 += 1
	if die1 >= 6:
		die1 = 2
	die2 = die1
	$Die1.fix(die1)
	$Die2.fix(die2)
