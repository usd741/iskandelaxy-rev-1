extends Node2D

const GAME_OVER_SCENE = preload("res://ui/game_over/game_over.tscn")
const NEXT_STAGE_SCENE = preload("res://ui/next_stage/next_stage.tscn")
const PAUSE_MENU_SCENE = preload("res://ui/pause_menu/pause_menu.tscn")

#Флаг, чтобы игра не заканчивалась дважды одновременно
var is_game_ended = false


func _ready():
	is_game_ended = false
	Events.lives_changed.connect(_on_lives_changed) #Подписываемся на изменение жизней
	check_game_over()
	Globals.current_level =2
	

func _unhandled_input(event):
	if not is_game_ended:
		if event.is_action_pressed("ui_cancel"):
			get_tree().paused = true
			add_child(PAUSE_MENU_SCENE.instantiate())


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
		get_tree().paused = true
		add_child(GAME_OVER_SCENE.instantiate())
		

func win_level():
	if is_game_ended:
		return # Защита от двойного срабатывания
	is_game_ended = true
	
	Globals.current_level += 1
	
	if Globals.current_level > Globals.max_unlocked_level:
		Globals.max_unlocked_level = Globals.current_level
	
	print("ПОБЕДА!")
	get_tree().paused = true
	add_child(NEXT_STAGE_SCENE.instantiate()) # Показываем экран
