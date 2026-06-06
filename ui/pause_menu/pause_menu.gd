extends CanvasLayer


# Ссылки на кнопки (не забудь привязать их в инспекторе или через @onready)
@onready var btn_resume: Button = $MarginContainer/VBoxContainer/btn_resume
@onready var btn_restart: Button = $MarginContainer/VBoxContainer/btn_restart
@onready var btn_main_menu: Button = $MarginContainer/VBoxContainer/btn_main_menu

func _ready() -> void:
	# Меню должно работать, даже когда игра на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Подписываем кнопки на нажатия (можно сделать и через инспектор, но так надёжнее)
	btn_resume.pressed.connect(_on_resume_pressed)
	btn_restart.pressed.connect(_on_restart_pressed)
	btn_main_menu.pressed.connect(_on_main_menu_pressed)



func _on_resume_pressed() -> void: #1. Кнопка "Продолжить"
	get_tree().paused = false # Снимаем паузу
	queue_free() # Удаляем меню

func _on_restart_pressed() -> void: #2. Кнопка "Перезапустить уровень"
	get_tree().paused = false # Снимаем паузу
	get_tree().reload_current_scene() # Перезагружаем текущую сцену

func _on_main_menu_pressed() -> void: #3. Кнопка "Главное меню"
	get_tree().paused = false # Снимаем паузу
	Globals.save_game() # Сохраняем прогресс перед выходом
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")


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
