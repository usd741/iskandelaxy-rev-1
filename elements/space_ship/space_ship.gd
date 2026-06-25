extends CharacterBody2D

const ROCKET_SCENE = preload("res://elements/rocket/rocket.tscn")
const SPEED = 100.0

@export var shoot_cooldown_duration: float = 0.0 #Настраиваемая переменная для кулдауна (можно менять в инспекторе)

#---Переменные здоровья---#
@export var max_health: int = 3 #Максимальное здоровье, можно менять в инспекторе
var current_health: int = 3 #Текущее здоровье
var is_invulnerable: bool = false #Флаг неуязвимости
#-------------------------#

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var shoot_cooldown: float = 0.0

func _physics_process(_delta):
	# Уменьшаем таймер перезарядки каждый кадр
	if shoot_cooldown > 0:
		shoot_cooldown -= _delta

	if Input.is_action_just_pressed("ui_accept"):
		shot()
	
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	move_and_slide()

func shot():
	#Проверяем можем ли стрелять
	if shoot_cooldown > 0:
		#Перезарядка еще идет - воспроизводим звук щелчка
		AudioManager.play_player_empty_shot()
		return
		
	shoot_cooldown = shoot_cooldown_duration #Запускаем таймер перезарядки
	#Стреляем
	AudioManager.play_player_shoot()
	var rocket = ROCKET_SCENE.instantiate()
	rocket.global_position = global_position + Vector2(0, -10)
	add_child(rocket)

func take_damage():
	if is_invulnerable: #Если игрок неуязвим игнорируем урок
		print("INVURNERABLE") 
		return
	current_health -= 1 #Уменьшяем здоровье на 1
	print("DAMAGE TAKEN! HEALTH:", current_health, "/", max_health)
	Events.health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()	

func die():
	print("PLAYER DIED! LIVES LEFT:", Globals.lives)
	
	#Отключаем игрока
	visible = false
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	#Отнимаем жизнь
	Globals.change_lives(-1)
	#Ждем 1 секунду и респавнимся
	await get_tree().create_timer(1.0).timeout
	respawn()

func respawn():
	print("RESPAWN!")
	
	#восстанавливаем здоровье
	current_health = max_health
	
	#Отрпавляем сигнал в UI для обновления полоски жизни
	Events.health_changed.emit(current_health, max_health)
	
	#Включаем игрока
	visible = true
	collision_shape.set_deferred("disabled", false)
	set_physics_process(true)

	#Делаем игрока неуязвимым на 2 секунды
	is_invulnerable = true
	await await get_tree().create_timer(2).timeout
	is_invulnerable = false
	print("PLAYER IS VULNERABLE NOW")

func point_plus():
	print("POINT TAKEN")
