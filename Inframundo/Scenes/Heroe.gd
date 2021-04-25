extends Sprite 
var can_move

#Vectores para el personaje
var dir = {
	"Down": Vector2(40,20),
	"Left": Vector2(-40,20),
	"Right": Vector2(40,-20),
	"Up": Vector2(-40,-20)
}
# Para el movimiento del personaje
func _physics_process(delta): 
	if Input.is_action_pressed("ui_up"):
		move_to(dir.Up)
	if Input.is_action_pressed("ui_down"):
		move_to(dir.Down)
	if Input.is_action_pressed("ui_right"):
		move_to(dir.Right)
	if Input.is_action_pressed("ui_left"):
		move_to(dir.Left)
		
		
		
#funcion de la animacion del personaje		
func move_to(dir):
	can_move = false
	$Tween.interpolate_property(self, "position",
					position, position + dir, 0.5,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	can_move = true
	
