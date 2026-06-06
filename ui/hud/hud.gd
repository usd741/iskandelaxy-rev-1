extends CanvasLayer

@onready var points_label =$"VBoxContainer/Points&Lives/Points"


func _ready():
	Events.points_changed.connect(update_points)
	
func update_points(points: int):
	points_label.text = str(points)
