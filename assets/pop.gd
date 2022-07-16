extends AnimatedSprite

var disappear_delay = 1

func _process(delta):
	disappear_delay -= delta
	if disappear_delay < 0:
		queue_free()
