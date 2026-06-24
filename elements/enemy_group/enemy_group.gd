extends Node2D

const ROW_STEP = 0.02
const SPEED_BOOST = 2.5

@onready var block_timer: = $BlockTimer
@onready var shot_timer: = $ShotTimer
@onready var shot_timer_2: = $ShotTimer2

var direction: = Vector2.RIGHT
var direction_down: = Vector2.DOWN
var speed = 10
var random = randi_range(1, 100)
var game_manager_node = null
var total_enemies = 0 #Сколько врагов было создано
var dead_enemies_count = 0 #Сколько врагов уже уничтожено

#----------------------------------------------

func _ready():
	#Ищем узел с именем Game во всем дереве сцены
	game_manager_node = get_tree().root.get_node("Level")
	if game_manager_node == null:
		print("ОШИБКА: не удалось найти узел Level")
	else:
		print("ЧЕТКО: нашли узел Level")
	
	count_initial_enemies() #Считаем всех врагов которые уже есть в сцене
		
func count_initial_enemies():
	total_enemies = 0
	for child in get_children():
		if child != block_timer and child != shot_timer and child != shot_timer_2:
			total_enemies += 1
			#Подписываемся на сигнал смерти каждого врага
			if child.has_signal("died"):
				child.died.connect(_on_enemy_unit_died)
	
	print("Итого врагов на уровне:", total_enemies)

#Эта функция вызывается при уничтожении врага
func _on_enemy_unit_died():
	dead_enemies_count += 1
	
	#Проверяем победу
	if dead_enemies_count >= total_enemies:
		if game_manager_node:
			game_manager_node.call_deferred("win_level")
		print("Победа! Враги уничтожены.")

func _process(delta: float):
	global_position += direction * speed * delta
	global_position += direction_down * ROW_STEP


func change_direction():
	print("change direction")
	if block_timer.time_left > 0:
		return
	direction = Vector2.LEFT if direction == Vector2.RIGHT else Vector2.RIGHT
	speed += SPEED_BOOST
	block_timer.start()
	print("direction changed")


func _on_shot_timer_timeout():	
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		return
	
	#Пробуем 3 раза найти готового врага (чтобы не было пауз)
	for attempt in range(3):
		var random_enemy = enemies.pick_random()
		#Проверяем готов ли враг стрелять (его fire_rate <=0)
		if random_enemy.fire_timer <= 0:
			random_enemy.shot()
			#Сбрасываем его таймер (он сам установит свой интервал в shot() )
			random_enemy.fire_timer = 1.0 / random_enemy.fire_rate
			break #Нашли одного - выходим из цикла

func _on_shot_timer_2_timeout():	
	var enemies = get_tree().get_nodes_in_group("enemy_tier_2")
	if enemies.size() == 0:
		return
	
	#Пробуем 3 раза найти готового врага (чтобы не было пауз)
	for attempt in range(3):
		var random_enemy = enemies.pick_random()
		#Проверяем готов ли враг стрелять (его fire_rate <=0)
		if random_enemy.fire_timer <= 0:
			random_enemy.shot()
			#Сбрасываем его таймер (он сам установит свой интервал в shot() )
			random_enemy.fire_timer = 1.0 / random_enemy.fire_rate
			break #Нашли одного - выходим из цикла
