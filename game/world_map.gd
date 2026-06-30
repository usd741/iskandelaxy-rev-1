extends Control


#---Ссылки на узлы---#
@onready var player_marker: ColorRect = $PlayerMarker
@onready var level_nodes_container: Control = $LevelNodes
@onready var start_button: Button = $VBoxContainer/NextLevelButton
#---Ссылки на узлы---#

#---Цвета ждя состояния уровней---#
const COLOR_COMPLETED := Color(0.0, 0.8, 0.0) #Пройдет
const COLOR_CURRENT := Color(0.0, 0.5, 1.0) #Текущий
const COLOR_LOCKED := Color(1.0, 0.2, 0.2) #Закрытый
const COLOR_LOCKED_DARK := Color(0.5, 0.1, 0.1) #Закрытый для мигания
#---Цвета ждя состояния уровней---#

#---Переменный---#
var target_marker_position: Vector2 #Позиция, куда должен прийти маркер
var marker_way_animation_duration: float = 2.0 #время анимации перехода маркера
var color_blinking_duration: float = 1.0 #время мигания

func _ready() -> void:
	_color_level_nodes() #раскрашиваем все узлы уровней
	_update_marker_position() #определяем где должен стоять маркер
	start_button.pressed.connect(_on_next_level_button_pressed) #связали сигнал кнопки с функцией
	if Globals.should_animate_marker: #проверяем нужна ли анимация
		var start_node_index: int = Globals.current_level -2 #Находим узел, где маркер должен стоять ДО начала движения (предыдущий уровень)
		if start_node_index >= 0:
			var start_node: ColorRect = level_nodes_container.get_child(start_node_index)
			player_marker.global_position = start_node.global_position
		_animate_marker_movement() #если да, то маркер едет от старой к новой позиции
		await get_tree().create_timer(marker_way_animation_duration).timeout
		Globals.should_animate_marker = false #сбрасываем маркер анимации
	else:
		player_marker.global_position = target_marker_position #переносим марке без анимации
		Globals.should_animate_marker = false #сбрасываем маркер анимации

func _color_level_nodes() -> void:
	#проходимся по всем дочерним узлам контейнера LevelNodes
	for i in range(level_nodes_container.get_child_count()):
		var level_node: ColorRect = level_nodes_container.get_child(i)
		var level_number: int = i + 1

		if level_number < Globals.current_level:
			level_node.color = COLOR_COMPLETED
		elif level_number == Globals.current_level:
			level_node.visible = true
		else:
			level_node.visible = false
			#_animate_node_blink(level_node) #запускаем мигание

func _update_marker_position():
	var node_index: int = Globals.current_level -1 #обозначаем что индекс узла это -1 от технического номера уровня. То есть 4 уровень для игрока = 3 уровень для кода
	var target_node: ColorRect = level_nodes_container.get_child(node_index) #Назначаем целевой узел. Предварительно найдя этот узел в контейнере узлов (жестко привязав за тип узла ColorRect)
	target_marker_position = target_node.global_position


#---Анимация маркера---#
func _animate_marker_movement():
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(player_marker, "global_position", target_marker_position, marker_way_animation_duration)

func _on_next_level_button_pressed():
	AudioManager.play_click()
	var next_level_path: String = Globals.get_level_path()
	TransitionManager.change_scene_with_fade(next_level_path)

func _animate_node_blink(node: ColorRect) -> void:
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(node, "color", COLOR_LOCKED_DARK, color_blinking_duration)
	tween.tween_property(node, "color", COLOR_LOCKED, color_blinking_duration)
