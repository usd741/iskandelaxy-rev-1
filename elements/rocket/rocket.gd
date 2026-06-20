extends CharacterBody2D

@onready var player_laser_animation = $AnimatedSprite2D

const SPEED = 200.0

func _ready() -> void:
	player_laser_animation.play("default") # Запускаем анимацию ОДИН РАЗ при создании пули


func _physics_process(delta: float):
	var collision = move_and_collide(Vector2.UP * SPEED * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("destroy"):
			collider.destroy()
			print("Kill")
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
