extends Sprite 
var can_move = true

#Vectores para el personaje
var dir = {
	"Down": Vector2(40,20),
	"Left": Vector2(-40,20),
	"Right": Vector2(40,-20),
	"Up": Vector2(-40,-20)
}
# Para el movimiento del personaje
# Raycast que permite mover si, y siempre si, no choque con algo.
func _physics_process(delta): 
	if can_move:
		if Input.is_action_pressed("ui_up") and !$Up.is_colliding():
			move_to(dir.Up)
		if Input.is_action_pressed("ui_down") and !$Down.is_colliding():
			move_to(dir.Down)
		if Input.is_action_pressed("ui_right") and !$Right.is_colliding():
			move_to(dir.Right)
		if Input.is_action_pressed("ui_left") and !$Left.is_colliding():
			move_to(dir.Left)
		
#Movimiento según donde se mueva el prota
func move_to(direction):
	$anim.play("Walk")
	match direction:
		dir.Up:
			set_frame(2)
		dir.Down:
			set_frame(0)
		dir.Right:
			set_frame(1)
		dir.Left:
			set_frame(3)
			
	can_move =  false
	$Tween.interpolate_property(self, "global_position",
					global_position, global_position + direction, 0.5,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	can_move = true
	
