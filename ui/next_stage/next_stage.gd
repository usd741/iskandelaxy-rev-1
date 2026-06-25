extends CanvasLayer

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel #ссылка на текст очков

func _ready() -> void:
	AudioManager.play_stage_clear() # Воспроизводим звук очистки уровня при загрузке этого экрана
	animate_score() #запускаем анимацию очков
	process_mode = Node.PROCESS_MODE_ALWAYS


func animate_score():
	var tween = create_tween()
	tween.tween_method(
		func(val: int): score_label.text = "Набрано очков: " + str(val),
		0, # начальное значение
		Globals.points, #конечное значение
		2.0 #длительность в секундах
	)

func _on_btn_next_stage_pressed() -> void:
	AudioManager.play_click() # Воспроизводим звук клика при нажатии на кнопку
	clear_bullets() #чистим пули
	clear_power_up() #чистим павер апы
	#var next_path = Globals.get_level_path()
	Globals.save_game()
	#if next_path != "":
	TransitionManager.change_scene_with_fade("res://game/world_map.tscn")
	#else:
	#	TransitionManager.change_scene_with_fade("res://ui/main_menu/main_menu.tscn")


func _on_btn_main_menu_pressed() -> void:
	AudioManager.play_click() # Воспроизводим звук клика при нажатии на кнопку
	clear_bullets() #чистим пули
	clear_power_up() #чистим павер апы
	Globals.save_game()
	TransitionManager.change_scene_with_fade("res://ui/main_menu/main_menu.tscn")


func clear_bullets():
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()

func clear_power_up():
	var power_up = get_tree().get_nodes_in_group("power_up")
	print("найдено Power ups в группе:", power_up.size())
	for i in range(power_up.size() -1, -1, -1):
		var node = power_up[i]
		print("Удаляем: ", node.name, " | Путь: ", node.get_path())
		power_up[i].queue_free()
	print("Power ups cleared")
