extends Node

signal points_changed(points: int)
signal points_got(diff: int)
signal lives_changed(lives: int)
signal enemy_died()
signal health_changed(current_health: int, max_health: int)