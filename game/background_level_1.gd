extends ParallaxBackground

@export var scroll_speed: float = 20.0

func _process(delta):
	#Сдвигаем фон влево, умножая скорость на время между кадрами для плавности
	scroll_offset.y += scroll_speed * delta
