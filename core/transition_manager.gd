extends Node

#Переменная в которой будет храниться черный экран
var fade_screen: ColorRect

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS #Чтобы анимация работала даже если игра поставлена на паузу
	#Создаем узел ColoreRect (черный прямоугольник)
	fade_screen = ColorRect.new()
	#Задаем ему цвет: Красный=0, Зеленый=0, Синий=0, Альфа=0 (полностью прозрачный)
	fade_screen.color = Color(0, 0, 0, 0)
	#Растягиваем его на весь экран (специальная команда Godot для UI элементов)
	fade_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	#Создаем CanvasLayer (Холст), т.к. холсты в Godot рисуются поверх всего остального
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 #Устанавливаем высокий слой, чтобы он точно был поверх всего

	#Собираем матрешку: добавляем черный экран в холст, а холст в менеджер
	canvas_layer.add_child(fade_screen)
	add_child(canvas_layer)
	fade_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE #Чтобы черный экран не блокировал клики мыши


func fade_out():
	fade_screen.mouse_filter = Control.MOUSE_FILTER_STOP #Блокируем клики мыши, чтобы игрок не мог взаимодействовать с игрой во время анимации

	#Создаем новый объект Tween (инструмент для плавных анимаций)
	var tween = create_tween()

	#Говорим ему что именно нужно анимировать
	tween.tween_property(
		fade_screen, #Объект который мы меняем
		"color", #Какое свойство меняем (цвет)
		Color(0, 0, 0, 1), #Конечное значение (черный, но уже полностью непрозрачный)
		0.25 #Длительность анимации в секундах
	)
	await tween.finished #Ждем пока анимация закончится


func fade_in():
	fade_screen.mouse_filter = Control.MOUSE_FILTER_STOP #Блокируем клики мыши, чтобы игрок не мог взаимодействовать с игрой во время анимации
	fade_screen.color = Color(0, 0, 0, 1) #Начинаем с черного экрана
	#Создаем новый объект Tween (инструмент для плавных анимаций)
	var tween = create_tween()

	#Говорим ему что именно нужно анимировать
	tween.tween_property(
		fade_screen, #Объект который мы меняем
		"color", #Какое свойство меняем (цвет)
		Color(0, 0, 0, 0), #Конечное значение (черный, но уже полностью прозрачный)
		0.25 #Длительность анимации в секундах
	)
	await tween.finished #Ждем пока анимация закончится
	fade_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE #Чтобы черный экран не блокировал клики мыши


func change_scene_with_fade(path: String) -> void:
	await fade_out() #Сначала плавно затемняем экран
	get_tree().change_scene_to_file(path) #Меняем сцену
	await get_tree().process_frame #Ждем один кадр, чтобы новая сцена успела загрузиться
	get_tree().paused = false #На всякий случай снимаем паузу, если она была поставлена
	await fade_in() #Плавно возвращаем видимость экрана