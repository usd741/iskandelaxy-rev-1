extends CharacterBody2D

@export var speed = 250
@export var slow_duration = 0.5 #Время полета с половинной скоростью
@export var acceleration_duration = 0.5 #Время разгона до полной скорости после замедления
@export_range(-1.0, 1.0, 0.01) var acceleration_curve = -0.7 #Кривая разгона

@onready var muzzle_particle: GPUParticles2D = $TrailParicles

var time_alive = 0.0

func _ready():
	muzzle_particle.emitting = true
	

func _physics_process(delta):
	time_alive += delta #Накапливаем время жизни пули
	var current_speed = 0.0 #Рассчитываем текущую скорость в зависимоти от времени жизни
	if time_alive <= slow_duration: #Первые 0,5 секунд: скорость меньше насколько умножается после запятой
		current_speed = speed * 0.1
	else:
		#Нелинейный разгон до полной скорости
		var time_in_acceleration = time_alive - slow_duration
		var progress = min(time_in_acceleration / acceleration_duration, 1.0)
		#ease() в Godot: отрицательные значения дают "ease-in" (мягкий старт)
		var eased_progress = ease(progress, acceleration_curve)
		
		#Преобразуем eased-progress в диапазон скорости [0.5-1.0]
		current_speed = speed * lerp(0.5, 1.0, eased_progress)
		
		
	var collision = move_and_collide(Vector2.DOWN * delta * current_speed)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("take_damage"):
			collider.take_damage()
			muzzle_particle.emitting = false
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
