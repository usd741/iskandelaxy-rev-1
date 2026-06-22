extends Label


func _ready():
	Events.points_changed.connect(update_score)
	update_score(Globals.points) #Показываем текущие очки

func update_score(points: int):
	text = str(points)
