extends CharacterBody2D

@export var speed = 50
@export var boat_rect := Rect2(Vector2(100, 100), Vector2(200, 150))

func _physics_process(delta):
	var input_vector = Input.get_vector("left", "right", "up", "down")

	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
		play_walk_animation(input_vector)
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()
	move_and_slide()


func play_walk_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			$AnimatedSprite2D.play("right_walk")
		else:
			$AnimatedSprite2D.play("left_walk")
	else:
		if dir.y > 0:
			$AnimatedSprite2D.play("down_walk")
		else:
			$AnimatedSprite2D.play("up_walk")
