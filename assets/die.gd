class_name Die
extends AnimatedSprite

export var is_rolling = false

var roll_delay = 0


func _ready():
	pass


func _process(delta):
	if is_rolling:
		if roll_delay > 0:
			roll_delay -= delta
		if roll_delay <= 0:
			var i = randi() % 6
			if i != frame:
				frame = i
				roll_delay = 0.050

func roll():
	is_rolling = true

func hold(weights):
	is_rolling = false
	frame = randi() % 6
	var total_weight = 0
	for w in weights:
		total_weight += w
	if total_weight <= 0:
		return
	var offset = randi() % total_weight
	frame = 0
	for w in weights:
		if offset < w:
			return
		offset -= w
		frame += 1

func fix(number):
	is_rolling = false
	if number == 7:
		frame = 7
	elif number >= 1:
		frame = number - 1
	else:
		frame = 6

func get_result():
	return 1 + frame
