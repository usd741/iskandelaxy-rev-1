extends Area2D


# --- НАСТРОЙКИ (Мы будем менять их в инспекторе для разных бонусов) ---
@export var bullet_upgrade_scene: PackedScene #сцена улучшенной пули (если назначена)
@export var upgrade_duration: float = 5.0 #Длительность улучшения в секундах
@export var points_value: int = 1 #Сколько очков дает этот бонус
@export var speed: float = 200.0 #Как быстро он падает

#Ссылка на спрайт, чтобы менять картинку
@onready var sprite = $Sprite
@onready var sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D #Ссылка на коллайдер

var is_collected: bool = false #Флаг, чтобы бонус не собирался дважды

func _physics_process(delta):
	if is_collected:
		return	
	position.y += speed * delta
		

func _on_visible_on_screen_notifier_2d_screen_exited():
	if is_collected:
		return
	queue_free()


func _on_body_entered(body: Node2D) -> void:	
	if is_collected:
		return		
	if body.has_method("point_plus"):
		print("Бонус подобран!")
		is_collected = true #Подобран
		#---Отключаем всё, что может вызвать повторную коллизию---#
		collision_shape.set_deferred("disabled", true)
		set_physics_process(false)			
		#Воспроизводим звук и собираем бонус
		sound.play()
		body.point_plus()
		Globals.change_points(+points_value)			
		if bullet_upgrade_scene != null and body.has_method("upgrade_weapon"):
			body.upgrade_weapon(bullet_upgrade_scene, upgrade_duration)
			print("Weapon upgrade activated")
		visible = false
		await get_tree().create_timer(5.0).timeout  # Страховка
		print("========Удаляем бонус========")
		queue_free()
	else:
			queue_free()