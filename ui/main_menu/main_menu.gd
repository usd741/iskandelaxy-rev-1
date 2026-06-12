extends Control

@onready var button_continue: Button = $MarginContainer/VBoxContainer/Button_Continue
@onready var button_scores: Button = $MarginContainer/VBoxContainer/Button_Scores

func _ready() -> void:
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

func check_saved_game():
	#Проверка есть ли сохранения, в противном случае кнопка продолжить заблочена
	button_continue.disabled = not Globals.has_save()

func _on_button_new_game_pressed():
	AudioManager.play_click() # Воспроизводим звук клика при нажатии на кнопку
	Globals.reset()
	TransitionManager.change_scene_with_fade("res://game/game.tscn")


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
