extends Control

@onready var button_continue: Button = $MarginContainer/VBoxContainer/Button_Continue
@onready var button_scores: Button = $MarginContainer/VBoxContainer/Button_Scores

func _ready() -> void:
	check_saved_game()
	button_scores.disabled = true

func check_saved_game():
	#Проверка есть ли сохранения, в противном случае кнопка продолжить заблочена
	button_continue.disabled = not Globals.has_save()

func _on_button_new_game_pressed():
	Globals.reset()
	get_tree().change_scene_to_file("res://game/game.tscn")


func _on_button_continue_pressed() -> void:
	# 1. Загружаем данные из файла в переменные Globals
	Globals.load_game()
	# 2. Получаем путь к сцене (текст, например "res://game/level_2.tscn")
	var saved_level_path = Globals.get_level_path()
	# 3. Переходим на эту сцену, используя инструмент текущего узла (get_tree)
	get_tree().change_scene_to_file(saved_level_path)


func _on_button_scores_pressed() -> void:
	pass # Replace with function body.
