extends Node2D

const GAME_OVER_SCENE = preload("res://ui/game_over/game_over.tscn")
const NEXT_STAGE_SCENE = preload("res://ui/next_stage/next_stage.tscn")

#Флаг, чтобы игра не заканчивалась дважды одновременно
var is_game_ended = false


func _ready():
	get_tree().paused = false
	is_game_ended = false
	Events.lives_changed.connect(_on_lives_changed) #Подписываемся на изменение жизней
	check_game_over()
	

#Обработка изменений жизней
func _on_lives_changed(new_lives):
	if is_game_ended: return #Игнорируем изменения, если игра уже кончилась
	print("Жизни изменились:", new_lives)
	check_game_over()


#Проверка на проигрышь
func check_game_over():
	if is_game_ended: return #Если игра уже закончена, ничего не делаем
	
	if Globals.lives <= 0:
		is_game_ended = true
		print("GAME OVER")
		add_child(GAME_OVER_SCENE.instantiate())
		get_tree().paused = true #Опционально: остановить физику игры, чтобы враги не двигались

func win_level():
	if is_game_ended:
		return # Защита от двойного срабатывания
	is_game_ended = true
	print("ПОБЕДА!")
	add_child(NEXT_STAGE_SCENE.instantiate()) # Показываем экран
	get_tree().paused = true
