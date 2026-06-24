extends CharacterBody2D

#const BULLET_SCENE = preload("res://elements/enemy_bullet/enemy_bullet.tscn")

const POINT_BRONZE_SCENE = preload("res://elements/powerUp/power_up_bronze.tscn")
const POINT_GOLD_SCENE = preload("res://elements/powerUp/power_up_gold.tscn")
const POINT_DIAMOND_SCENE = preload("res://elements/powerUp/power_up_diamond.tscn")

@export var powerup_scenes: Array[PackedScene] = [POINT_GOLD_SCENE, POINT_DIAMOND_SCENE, POINT_DIAMOND_SCENE]

@onready var raycast_left := $RayCastLeft
@onready var raycast_right := $RayCastRight
@onready var death_particle: GPUParticles2D = $DeathParticles
@onready var enemy_sprite: Sprite2D = $Sprite2D

#---Базовые характеристики---#
@export var max_health: int = 1
@export var bullet_speed: float = 150.0
@export var points_reward: int = 10
#---Базовые характеристики---#

#---Стрельба---#
@export var bullet_scene: PackedScene
@export var fire_rate: float = 2.0 #Выстрелов в секунду
@export var bullet_damage: int = 1
#---Стрельба---#

#---Бонусы---#
@export var powerup_scene: Array[PackedScene] = []
@export var powerup_drop_chance: float = 0.3 #шанс выпадания бонуса (0.0 - 1.0)
#---Бонусы---#

#---Визуал---#
@export var sprite_texture: Texture2D #Спрайт врага
@export var tint_color: Color = Color.WHITE #Цветовой оттеннок
#---Визуал---#

#---Сигнал---#
signal died
#---Сигнал---#

#---Переменные состояния---#
var current_health: int
var fire_timer: float = 0.0
#---Переменные состояния---#

#-------------------------#

func _ready():
	add_to_group("enemy")
	current_health = max_health #Устанавливаем здоровье из @export
	death_particle.emitting = false

	#Применяем визуальные настройки
	if sprite_texture:
		enemy_sprite.texture = sprite_texture
	enemy_sprite.modulate = tint_color
		

func _physics_process(_delta):
	# Движение и разворот
	if raycast_left.is_colliding() or raycast_right.is_colliding():
		get_tree().call_group("enemy_group", "change_direction")

	#Обратный отчет таймера готовности стрельбы
	
	if fire_timer > 0:
		fire_timer -= _delta
		


func take_damage(amount: int): #система здоровья
	AudioManager.play_regular_explosion()
	current_health -= amount

	#Визуальный эффект попадания (мигание)
	enemy_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	enemy_sprite.modulate = tint_color

	if current_health <= 0:
		destroy()

func destroy():
	AudioManager.play_regular_explosion()
	set_physics_process(false)
	set_process(false)
	$AnimatedSprite2D.visible = false
	enemy_sprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	#Начисляем очки
	Globals.change_points(points_reward)

	#Спавним бонус с шансом
	if randf() < powerup_drop_chance:
		spawn_powerup()
	#else: #Если бонус не выпал можно создать маленькое очко (по желанию)
		#var point_single = POINT_BRONZE_SCENE.instantiate()
		#point_single.global_position = global_position
		# Явно добавляем в группу
		#if not point_single.is_in_group("power_up"):
		#	point_single.add_to_group("power_up")
		#get_tree().root.add_child(point_single)
		#print("SINGLE POINT CREATED")
	print("ENEMY DIE EVENT EMITTED")
	died.emit() #Сигнал о смерти врага
	print("EXPLOSION PARTICLE")
	Events.enemy_died.emit()
	death_particle.one_shot = true
	death_particle.lifetime = 0.5
	death_particle.emitting = true
	death_particle.finished.connect(clean_after_death)

func clean_after_death():
	queue_free()


func spawn_powerup():
	if powerup_scenes.is_empty():
		return #Если список сцен паур-апов пуст, ничего не делаем
	var random_scene = powerup_scenes.pick_random() #Выбираем случайный бонус из списка
	var powerup = random_scene.instantiate() #Создаем его
	powerup.global_position = global_position #Ставим туда, где был враг
	
	# Явно добавляем в группу
	if not powerup.is_in_group("power_up"):
		powerup.add_to_group("power_up")
		print("Power-up added to group 'power_up':", powerup.name)
	
	get_tree().root.add_child(powerup)

func shot():
	if not bullet_scene:
		return #Если сцена пули пуста, не стреляем

	print("SHOT")
	AudioManager.play_enemy_tier1_shoot()
	var bullet = bullet_scene.instantiate()
	bullet.global_position += global_position + Vector2(0, 10.0)
	
	#Если у пули есть параметр урона, устанавливаем его
	if bullet.has_method("set_damage"):
		bullet.set_damage(bullet_damage)
	elif "damage" in bullet:
		bullet.damage = bullet_damage
	
	get_tree().root.add_child(bullet)