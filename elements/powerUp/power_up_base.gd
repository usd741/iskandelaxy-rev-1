extends CharacterBody2D


# --- НАСТРОЙКИ (Мы будем менять их в инспекторе для разных бонусов) ---
@export var points_value: int = 100 #Сколько очков дает этот бонус
@export var speed: float = 100.0 #Как быстро он падает

#Ссылка на спрайт, чтобы менять картинку
@onready var sprite = $Sprite
@onready var sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D #Ссылка на коллайдер

var is_collected: bool = false #Флаг, чтобы бонус не собирался дважды

func _physics_process(delta):
	if is_collected:
		return	
	var collision = move_and_collide(Vector2.DOWN * delta * speed)
	if collision:
		var collider = collision.get_collider()
		print("Коллизия с: ", collider.name)  # ← ДОБАВЬ ЭТО

		if collider.has_method("point_plus"):
			print("Бонус подобран!")  # ← И ЭТО

			is_collected = true #Подобран
			#---Отключаем всё, что может вызвать повторную коллизию---#
			collision_shape.set_deferred("disabled", true)
			set_physics_process(false)			
			#---#
			#Воспроизводим звук и собираем бонус
			sound.play()			
			collider.point_plus()
			Globals.change_points(+points_value)
			visible = false			
			await get_tree().create_timer(5.0).timeout  # Страховка
			print("========Удаляем бонус========")
			queue_free()
		else:
			queue_free()
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	if is_collected:
		return
	queue_free()
