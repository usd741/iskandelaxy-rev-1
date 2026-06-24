extends Label

var _tween: Tween
var current_points: int #текущее значение очков

@export var animation_duration: float = 1.0

@export var value: int:
	set(new_points):
		if !is_node_ready():
			return
		#Если новое значение равно старому - анимация не нужна
		if new_points == current_points:
			return
		var tween = get_tween()
		tween.tween_method(update_score, current_points, new_points, animation_duration)
		current_points = new_points

func _ready():
	current_points = Globals.points
	update_score(Globals.points) #Показываем текущие очки
	Events.points_changed.connect(func(new_points): value = new_points)


func get_tween() -> Tween:
	if (_tween):
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	return _tween

func update_score(points: int):
	text = str(points)