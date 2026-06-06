extends CanvasLayer

@onready var green_screen: ColorRect = $ColorRect #ссылка на прямоугольник
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel #ссылка на текст очков

const TARGET_ALPHA = 0.75 #Целевое значение прозрачности, до которого будет идти фейд
var fade_speed = 1.0 #Скорость фейда - чем меньше, тем медленнее
var is_fading = true #Флаг, контролирующий, активен ли процесс перехода

func _ready():
	#Начинаем с полностью темного экрана
	green_screen.modulate.a = 0.0
	# Важно: разрешаем этому узлу работать даже когда игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS
	animate_score() #запускаем анимацию очков

func animate_score():
	var tween = create_tween()
	var display_value = 0 #переменнаю которую будем анимировать
	
	tween.tween_method(
		func(val: int): score_label.text = "Набрано очков: " + str(val),
		0, # начальное значение
		Globals.points, #конечное значение
		2.0 #длительность в секунда
	)

func _process(delta):
	#Если переход уже завершён, не выполняем лишние вычисления
	if not is_fading:
		return

	#Проверяем не достигли ли целевого значения
	if green_screen.modulate.a < TARGET_ALPHA:
		# Увеличиваем alpha с учётом времени кадра
		green_screen.modulate.a += fade_speed * delta
		
		#Защита от перелета из-за плавающей точки
		if green_screen.modulate.a > TARGET_ALPHA:
			green_screen.modulate.a = TARGET_ALPHA
			is_fading = false #Останавливаем дальнейшую обработку


func _on_button_pressed():
	queue_free()
	await get_tree().process_frame
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/game.tscn") # Твой путь к уровню
