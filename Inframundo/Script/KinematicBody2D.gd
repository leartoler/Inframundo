extends KinematicBody2D

#var speed = 8000
#var direction = Vector2()
var dialog_id = null


func _physics_process(delta:float) -> void:
	
#	if Input.is_action_pressed("ui_left"):
#		direction.x = -1
#	elif Input.is_action_pressed("ui_right"):
#		direction.x = 1
#	else:
#		direction.x = 0
				
#	if Input.is_action_pressed("ui_up"):
#		direction.x = -1
#	else:
#		direction.y = 0
		
#	move_and_slide(direction.normalized() * speed * delta)

	
	

	if dialog_id != null and Input.is_action_just_pressed("ui_accept"):
		Dialog.show_message(dialog_id)
	
