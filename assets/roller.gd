extends Node2D

export var is_monster = false

export var initial_roll_duration = 5.0
export var roll_duration = 5.0
export var hold_duration = 5.0

var roll_delay = 0
var hold_delay = 0

signal rolled()


func _ready():
	hold_delay = roll_duration
	if is_monster:
		hold_delay += initial_roll_duration
	roll_delay = hold_delay + hold_duration


func _process(delta):
	if hold_delay > 0:
		hold_delay -= delta
		if hold_delay <= 0:
			emit_signal("rolled")
	if roll_delay > 0:
		roll_delay -= delta
		if roll_delay <= 0:
			for die in [$Die1, $Die2, $Die3]:
				die.roll()
			hold_delay = roll_duration
			roll_delay = roll_duration + hold_duration

func roll(weights):
	for die in [$Die1, $Die2, $Die3]:
		die.hold(weights)
