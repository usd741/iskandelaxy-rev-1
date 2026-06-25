extends Node

var should_animate_marker: bool = false #Флаг для анимации карты на карте
var current_level: int = 1
var max_unlocked_level: int = 1

var level_scenes = {
	1: "res://game/level_1.tscn",
	2: "res://game/level_2.tscn",
	3: "res://game/level_3.tscn",
	4: "res://game/level_4.tscn"
}

var points: int = 0
var lives: int = 3

func reset():
	points = 0
	lives = 3
	current_level = 1
	max_unlocked_level = 1

func change_points(diff: int):
	points += diff
	Events.points_changed.emit(points) #Общее количество очков (основной счет)
	Events.points_got.emit(diff) #Получено очков за раз

func change_lives(diff: int):
	lives += diff
	Events.lives_changed.emit(lives)

func get_level_path() -> String:
	#current_level уже равен следующему уровню благодаря win_level()
	#Поэтому мы просто ищем путь для текущего значения current_level
	if level_scenes.has(current_level):
		return level_scenes[current_level]
	# Если уровня нет (например, current_level = 4) — 
	# возвращаем последний уровень из словаря
	var max_level = level_scenes.keys().max()
	return level_scenes[max_level]

	
func save_game() -> bool:
	var config = ConfigFile.new()
	#Записываем данные в раздел "progress"
	config.set_value("progress", "current_level", current_level)
	config.set_value("progress", "max_unlocked_level", max_unlocked_level)
	config.set_value("progress", "points", points)
	config.set_value("progress", "lives", lives)
	print("Game saved")
	#сохраняем файл на диск
	var error = config.save("user://savegame.cfg")
	#если error равен OK (то есть 0), значит всё прошло успешно
	return error == OK
	


func load_game() -> bool:
	var config = ConfigFile.new()
	
	#1. Пытаемся загрузить файл с диска
	#Если файла нет или он поврежден, config.load вернет ошибку (не ОК)
	if config.load("user://savegame.cfg") !=OK:
		return false #Сохранения нет! Сообщаем об этом (возвращаем false)
	
	#2. Если мы дошли до этой строки, значит файл успешно загрузился
	#Достаем значения используя "значения по умолчанию
	#Если ключа вдруг не будет, подставится безопасное значение
	current_level = config.get_value("progress", "current_level", 1)
	max_unlocked_level = config.get_value("progress", "max_unlocked_level", 1)
	points = config.get_value("progress", "points", 0)
	lives = config.get_value("progress", "lives", 1)
	print("Game loaded: Level ", current_level, " | Max Unlocked: ", max_unlocked_level, " | Points: ", points, " | Lives: ", lives)
	#3. Все успешно загружено из файла в переменные Globals
	return true

func has_save() -> bool:
	return FileAccess.file_exists("user://savegame.cfg")
