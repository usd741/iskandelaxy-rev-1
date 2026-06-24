extends Label

var _tween: Tween
var _is_animating: bool = false

@export var animation_duration: float = 0.15
@export var return_duration: float = 0.05


func _ready() -> void:
	visible = false #скрываем

	scale = Vector2(0.75, 0.75) #установили начальный масштаб

	Events.points_got.connect(_on_points_got) #Подключились к сигналу
	pivot_offset = size / 2

func _on_points_got(diff: int):
	if _is_animating: #Если анимация уже идет, игнорим
		return
	#Устанавливаем значение полученных points и делаем текст видимым
	text = "+" + str(diff)
	visible = true
	#генерируем случайный угол
	var random_angle = randf_range(-25.0, 25.0)
	#Содаем tween для пружинистой анимации
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.parallel().tween_property(self, "rotation_degrees", random_angle, animation_duration)
	_tween.parallel().tween_property(self, "scale", Vector2(1.8, 1.8), animation_duration)
	#Отметили что анимация в процессе
	_is_animating = true
	#Ждем окончания анимации + 0.2 секунды
	await get_tree().create_timer(animation_duration + 0.2).timeout
	_return_to_initial_state()

func _return_to_initial_state():
		if _tween:
			_tween.kill()
		
		_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
		#Возвращаем исходные размер и уг.поворот
		_tween.parallel().tween_property(self, "rotation_degrees", 0, return_duration)
		_tween.parallel().tween_property(self, "scale", Vector2(0.75, 0.75), return_duration)

		await _tween.finished
		visible = false
		_is_animating = false
