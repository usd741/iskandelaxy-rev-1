extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioManager.play_game_over() # Воспроизводим звук Game Over при загрузке этого экрана

func _on_button_pressed():
	AudioManager.play_click() # Воспроизводим звук клика при нажатии на кнопку
	clear_bullets() #чистим пули
	clear_power_up() #чистим павер апы
	Globals.reset()
	TransitionManager.change_scene_with_fade("res://game/game.tscn")

func _on_btn_main_menu_pressed() -> void:
	AudioManager.play_click() # Воспроизводим звук клика при нажатии на кнопку
	clear_bullets() #чистим пули
	clear_power_up() #чистим павер апы
	Globals.reset()
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
