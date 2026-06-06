extends CharacterBody2D


# --- НАСТРОЙКИ (Мы будем менять их в инспекторе для разных бонусов) ---
@export var points_value: int = 100 #Сколько очков дает этот бонус
@export var speed: float = 100.0 #Как быстро он падает

#Ссылка на спрайт, чтобы менять картинку
@onready var sprite = $Sprite

func _physics_process(delta):
	var collision = move_and_collide(Vector2.DOWN * delta * speed)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("point_plus"):
			collider.point_plus()
			Globals.change_points(+points_value)
			queue_free()
		else: 
			queue_free()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
