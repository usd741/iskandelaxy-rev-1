extends HBoxContainer

var RECT_SCENE = preload("res://ui/hud/lives_bar/live_rect.tscn")
@onready var life_icon: TextureRect = $Control/life_icon
@onready var life_label: Label = $Control/life_label


func _ready():
	#Подписываемся на сигнал изменения жизней
	Events.lives_changed.connect(update_lives)
	#Инициализируем отображение при старте
	update_lives(Globals.lives)	


func update_lives(lives: int):
	#Обновляем текст: "x3", "x2", "x1" и т.д.
	life_label.text = "x" + str(lives)
	if lives <= 1:
		life_icon.modulate = Color(1, 0.5, 0.5, 0.5) #Полупрозрачно
	else:
		life_icon.modulate = Color(1, 1, 1, 1.0) #Полная видимость
