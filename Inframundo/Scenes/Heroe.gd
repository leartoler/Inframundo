extends Sprite

var dir = {
	"Right": Vector2(40,20),
	"Down": Vector2(-40,20),
	"Up": Vector2(40,-20),
	"Left": Vector2(-40,-20)
}

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_up"):
		move_to(dir.Up)
		
func move_to(dir):
	$Tween.interpolate_property(self, "position",
					position, position + dir, 0.5,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
