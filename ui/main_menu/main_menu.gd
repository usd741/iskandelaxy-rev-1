extends Control

@onready var button_continue: Button = $MarginContainer/VBoxContainer/Button_Continue
@onready var button_scores: Button = $MarginContainer/VBoxContainer/Button_Scores


@onready var coffee_sprite: Sprite2D = $Control/Sprite2D_coffee
@onready var cup_sprite: Sprite2D = $Control/Sprite2D_cup
@onready var cup_sprite2: Sprite2D = $Control/Sprite2D_cup2
@onready var cup_sprite3: Sprite2D = $Control/Sprite2D_cup3

var coffee_orig: Vector2
var cup_orig: Vector2
var cup_orig2: Vector2
var cup_orig3: Vector2

const RADIUS: float =  300.0
const FORCE: float =  20.0
const SMOOTHING: float = 0.1
const PUSH_DISTANCE: float = 10.0



func _ready() -> void:
	coffee_orig = coffee_sprite.position
	cup_orig = cup_sprite.position
	cup_orig2 = cup_sprite2.position
	cup_orig3 = cup_sprite3.position


	check_saved_game()
	button_scores.disabled = true
	AudioManager.play_music(AudioManager.music_menu) #Запускаем музыку для меню

	# --- НАЧАЛО НОВОГО КОДА ДЛЯ ЗВУКА ---
	# Получаем ссылку на контейнер с кнопками
	var button_container = $MarginContainer/VBoxContainer

	# Перебираем все дочерние узлы в контейнере
	for child in button_container.get_children():
		# Проверяем, является ли дочерний узел кнопкой
		if child is Button:
			#Если да, то подключаем сигнал mouse_entered к функции play_hover
			child.mouse_entered.connect(AudioManager.play_hover)
	# --- КОНЕЦ НОВОГО КОДА ДЛЯ ЗВУКА ---

func _process(delta: float) -> void:
	move_sprite_away(coffee_sprite, coffee_orig)
	move_sprite_away(cup_sprite, cup_orig)
	move_sprite_away(cup_sprite2, cup_orig2)
	move_sprite_away(cup_sprite3, cup_orig3)


func move_sprite_away(sprite: Sprite2D, orig_pos: Vector2) -> void:
	var mouse_local = sprite.to_local(get_global_mouse_position())
	var distance = mouse_local.length()

	if distance < RADIUS and distance > 0:
		var push_dir = mouse_local.normalized() * -1
		var target_pos = orig_pos + push_dir * PUSH_DISTANCE
		sprite.position = sprite.position.lerp(target_pos, SMOOTHING)
	else:
		sprite.position - sprite.position.lerp(orig_pos, SMOOTHING)



func check_saved_game():
	#Проверка есть ли сохранения, в противном случае кнопка продолжить заблочена
	button_continue.disabled = not Globals.has_save()

func _on_button_new_game_pressed():
	AudioManager.play_click() # Воспроизводим звук клика при нажатии на кнопку
	Globals.reset()
	TransitionManager.change_scene_with_fade("res://game/level_1.tscn")


func _on_button_continue_pressed() -> void:
	AudioManager.play_click() # Воспроизводим звук клика при нажатии на кнопку

	# 1. Загружаем данные из файла в переменные Globals
	Globals.load_game()
	# 2. Получаем путь к сцене (текст, например "res://game/level_2.tscn")
	var saved_level_path = Globals.get_level_path()
	# 3. Переходим на эту сцену, используя инструмент текущего узла (get_tree)
	TransitionManager.change_scene_with_fade(saved_level_path)


func _on_button_scores_pressed() -> void:
	AudioManager.play_click() # Воспроизводим звук клика при нажатии на кнопку
	pass # Replace with function body.
