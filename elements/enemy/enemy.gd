extends CharacterBody2D

#-------------------------#

signal died

const BULLET_SCENE = preload("res://elements/enemy_bullet/enemy_bullet.tscn")

const POINT_BRONZE_SCENE = preload("res://elements/powerUp/power_up_bronze.tscn")
const POINT_GOLD_SCENE = preload("res://elements/powerUp/power_up_gold.tscn")
const POINT_DIAMOND_SCENE = preload("res://elements/powerUp/power_up_diamond.tscn")

@export var powerup_scenes: Array[PackedScene] = [POINT_GOLD_SCENE, POINT_DIAMOND_SCENE]

@onready var raycast_left := $RayCastLeft
@onready var raycast_right := $RayCastRight
@onready var death_particle: GPUParticles2D = $DeathParticles

#-------------------------#

func _ready():
	add_to_group("enemy")
	death_particle.emitting = false

func _physics_process(_delta):
	if raycast_left.is_colliding() or raycast_right.is_colliding():
		get_tree().call_group("enemy_group", "change_direction")


func destroy():
	AudioManager.play_regular_explosion()
	set_physics_process(false)
	set_process(false)
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	if randf() <0.3:
		spawn_powerup()
	else: #Есди бонус не выпал можно создать маленькое очко (по желанию)
		var point_single = POINT_BRONZE_SCENE.instantiate()
		point_single.global_position = global_position
		# Явно добавляем в группу
		if not point_single.is_in_group("power_up"):
			point_single.add_to_group("power_up")
		get_tree().root.add_child(point_single)
		print("SINGLE POINT CREATED")
	print("ENEMY DIE EVENT EMITTED")
	died.emit() #Сигнал о смерти врага
	print("Particle")
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
	AudioManager.play_enemy_tier1_shoot()
	print("SHOT")
	var bullet = BULLET_SCENE.instantiate()
	bullet.global_position += global_position + Vector2(0, 10.0)
	get_tree().root.add_child(bullet)
