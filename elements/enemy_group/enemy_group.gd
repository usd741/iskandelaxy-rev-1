extends Node2D

const ROW_STEP = 0.02
const SPEED_BOOST = 2.5

@onready var block_timer: = $BlockTimer
@onready var shot_timer: = $ShotTimer

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
	game_manager_node = get_tree().root.get_node("Game")
	if game_manager_node == null:
		print("ОШИБКА: не удалось найти узел Game")
	else:
		print("ЧЕТКО: нашли узел Game")
	
	count_initial_enemies() #Считаем всех врагов которые уже есть в сцене
		
func count_initial_enemies():
	total_enemies = 0
	for child in get_children():
		if child != block_timer and child != shot_timer:
			total_enemies += 1
			#Подписываемся на сигнал смерти каждого врага
			if child.has_signal("died"):
				child.died.connect(_on_enemy_unit_died)
	
	print("Всего врагов на уровне:", total_enemies)

#Эта функция вызывается при уничтожении врага
func _on_enemy_unit_died():
	dead_enemies_count += 1
	
	#Проверяем победу
	if dead_enemies_count >= total_enemies:
		if game_manager_node:
			game_manager_node.call_deferred("win_level")
		print("Победа! Все враги уничтожены.")

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
	if enemies.size() > 0:
		enemies.pick_random().shot()
