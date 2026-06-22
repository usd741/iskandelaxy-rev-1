extends TextureProgressBar

# Максимальное здоровье по умолчанию (должно совпадать с тем, что у игрока)
@export var default_max_health: int = 3
#Длительность анимации в секундах
@export var animation_duration: float = 0.25

#Ссылка на текущий Tween, чтобы мы могли остановить его если нужно
var health_tween: Tween


func _ready() -> void:
	#Подписываемся на сигнал изменения здоровья
	Events.health_changed.connect(_on_health_changed)

	#Инициализируем полоску при старте игры
	_on_health_changed(default_max_health, default_max_health)

func _on_health_changed(current_health: int, max_health: int):
	#Устанавливаем максимальное значение шкалы
	max_value = max_health
	#Если предыдущая анимация идет, останавливаем ее
	if health_tween and health_tween.is_valid():
		health_tween.kill()
	
	#Создаем новый Tween
	health_tween = create_tween()
	
	#Говорим tween: плавно меняй свойство "value" у этого узла от текущего значения до current_health за animation_duration секунд
	health_tween.tween_property(
	self, #Какой узел анимируем (сам health_bar)
	"value", #Какое свойство меняем
	current_health, #До какого значения
	animation_duration) #За сколько секунд
	#Устанавливаем текущее значение (Godot сам плавно или мгновенно обновит текстуру)