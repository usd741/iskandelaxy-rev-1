extends CharacterBody2D

const ROCKET_SCENE = preload("res://elements/rocket/rocket.tscn")
const SPEED = 100.0

@export var shoot_cooldown_duration: float = 2.0 #Настраиваемая переменная для кулдауна (можно менять в инспекторе)

var cool

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		shot()
	
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	move_and_slide()

func shot():
	AudioManager.play_player_shoot()
	var rocket = ROCKET_SCENE.instantiate()
	rocket.global_position = global_position + Vector2(0, -30)
	add_child(rocket)

func take_damage():
	print("TAKE DAMAGE")
	Globals.change_lives(-1)

func point_plus():
	print("POINT TAKEN")
