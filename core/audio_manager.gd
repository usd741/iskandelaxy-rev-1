extends Node
#AudioManager - отвечает за управление звуком в игре, включая фоновую музыку и звуковые эффекты.

#1 Предзагружаем звуки как ресурсы (чтобы не грузить их каждый раз при воспроизведении)
@onready var hover_sound: AudioStream = preload("res://assets/audio/ui/click_2.wav")
@onready var click_sound: AudioStream = preload("res://assets/audio/ui/sharp_echo.wav")
@onready var game_over_sound: AudioStream = preload("res://assets/audio/ui/misc_sound.wav")
@onready var stage_clear_sound: AudioStream = preload("res://assets/audio/ui/positive.wav")
@onready var pause_in_sound: AudioStream = preload("res://assets/audio/ui/sfx_sounds_pause7_in.wav")
@onready var pause_out_sound: AudioStream = preload("res://assets/audio/ui/sfx_sounds_pause7_out.wav")

# --- НОВЫЕ ЗВУКИ: ВЫСТРЕЛЫ И ВЗРЫВЫ ---
# Массивы звуков для рандомизации (чтобы не было одинаковых звуков подряд)
@onready var player_shoot_sounds: Array[AudioStream] = [
	preload("res://assets/audio/sfx/sfx_wpn_laser5.wav"),
	preload("res://assets/audio/sfx/sfx_wpn_laser7.wav"),
	preload("res://assets/audio/sfx/sfx_wpn_laser11.wav")]

@onready var enemy_tier1_shoot_sounds: Array[AudioStream] = [
	preload("res://assets/audio/sfx/sfx_wpn_cannon6.wav"),]

@onready var regular_explosion_sounds: Array[AudioStream] = [
	preload("res://assets/audio/sfx/sfx_exp_short_hard10.wav"),
	preload("res://assets/audio/sfx/sfx_exp_short_hard14.wav"),
	preload("res://assets/audio/sfx/sfx_exp_short_soft1.wav"),
	preload("res://assets/audio/sfx/sfx_exp_short_soft5.wav"),
	preload("res://assets/audio/sfx/sfx_exp_short_soft9.wav"),]

#- - - Музыка - - -
@onready var music_menu: AudioStream = preload("res://assets/audio/music/Ibra - Laser Alphabet_2.mp3")
@onready var music_level_1_3: AudioStream = preload("res://assets/audio/music/Ibra - Tin Meteor_2.mp3")
@onready var music_level_4_6: AudioStream = preload("res://assets/audio/music/Ibra - Tin Meteor_1.mp3")
@onready var music_level_7_10: AudioStream = preload("res://assets/audio/music/Ibra - Grid Thunder.mp3")

# Два плеера для плавного перехода между музыкой (кроссфейд)
@onready var music_player_a: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var music_player_b: AudioStreamPlayer = AudioStreamPlayer.new()

# ==========================================
# ПУЛЫ ЗВУКОВЫХ ИГРОКОВ
# ==========================================
#2 Создаем пул игроков для каждого типа звука (для одновременного воспроизведения нескольких звуков)
# Почему массив? Потому что в игре может быть несколько одновременных звуков (например, несколько кликов или звуковых эффектов), и нам нужно управлять ими без конфликтов.
var hover_sound_players: Array[AudioStreamPlayer] = []
var click_sound_players: Array[AudioStreamPlayer] = []
var game_over_sound_players: Array[AudioStreamPlayer] = []
var stage_clear_sound_players: Array[AudioStreamPlayer] = []
var pause_in_sound_players: Array[AudioStreamPlayer] = []
var pause_out_sound_players: Array[AudioStreamPlayer] = []
var player_shoot_sound_players: Array[AudioStreamPlayer] = []
var enemy_tier1_shoot_sound_players: Array[AudioStreamPlayer] = []
var regular_explosion_sound_players: Array[AudioStreamPlayer] = []

var active_music_player: AudioStreamPlayer 


#Сколько игроков в пуле - обычно 3-4 достаточно для UI
const POOL_SIZE: int = 4



func _ready():
	#Инициализируем пулы звуковых игроков для интерфейса
	_create_pool_interface(hover_sound_players, hover_sound, "hover_sound_player")
	_create_pool_interface(click_sound_players, click_sound, "click_sound_player")
	_create_pool_interface(game_over_sound_players, game_over_sound, "game_over_sound_player")
	_create_pool_interface(stage_clear_sound_players, stage_clear_sound, "stage_clear_sound_player")
	_create_pool_interface(pause_in_sound_players, pause_in_sound, "pause_in_sound_player")
	_create_pool_interface(pause_out_sound_players, pause_out_sound, "pause_out_sound_player")

	#Инициализируем пулы звуковых игроков для боя
	_create_pool_game(player_shoot_sound_players, "player_shoot_sound_player")
	_create_pool_game(enemy_tier1_shoot_sound_players, "enemy_tier1_shoot_sound_player")
	_create_pool_game(regular_explosion_sound_players, "regular_explosion_sound_player")

	#Инициализируем пулы звуковых игроков для музыки
	_setup_music_system()

func _create_pool_interface(pool: Array, sound: AudioStream, name_prefix: String):
	#Создаем новый аудиоплеер (пока он ни к чему не привязан)
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		
		#Даем ему читаемое имя для удобства отладки (например, "hover_sound_player_0", "hover_sound_player_1" и т.д.)
		player.name = name_prefix + "_" + str(i)

		#Назначаем звук, который он будет играть
		player.stream = sound

		#Еаправляем на шину SFX, чтобы потом можно было регулировать громкость всех звуковых эффектов
		player.bus = "UI"

		#Важно: добавляем плеер как дочерний узел к AudioManager, чтобы он был частью сцены и мог воспроизводить звук
		#Без этой строчки плеер существует в памяти, но не работает, так как не добавлен в сцену
		add_child(player)

		#Сохраняем ссылку на плеер в массиве, чтобы потом искать свободный
		pool.append(player)

func _create_pool_game(pool: Array, name_prefix: String):
	#Создаем новый аудиоплеер (пока он ни к чему не привязан)
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		
		#Даем ему читаемое имя для удобства отладки (например, "hover_sound_player_0", "hover_sound_player_1" и т.д.)
		player.name = name_prefix + "_" + str(i)
		#Еаправляем на шину SFX, чтобы потом можно было регулировать громкость всех звуковых эффектов
		player.bus = "SFX"

		#Важно: добавляем плеер как дочерний узел к AudioManager, чтобы он был частью сцены и мог воспроизводить звук
		#Без этой строчки плеер существует в памяти, но не работает, так как не добавлен в сцену
		add_child(player)

		#Сохраняем ссылку на плеер в массиве, чтобы потом искать свободный
		pool.append(player)
	
func _play_random_from_pool(pool: Array, sounds_array: Array[AudioStream]):
	if sounds_array.is_empty():
		return # Если массив звуков пуст, ничего не делаем

	#Ищем свободный плеер
	var available_player: AudioStreamPlayer = null
	for player in pool:
		if not player.playing:
			available_player = player
			break
	
	#Если все заняты, берем первый
	if available_player == null:
		available_player = pool[0]
	
	#Назначаем случайный звук из массива и воспроизводим
	available_player.stream = sounds_array.pick_random()
	available_player.play()

func _play_from_pool(pool: Array):
	#Перебираем все плееры в Массиве
	for player in pool:
		#Проверяем: играет ли сейчас этот плеер?
		if not player.playing:
			#Нашли свободный: Запускаем звук и выходим из функции
			player.play()
			return
	#Если дошли до этой строчки - все плееры заняты
	#Перезапускаем первый (он уже почти закончил играть)
	pool[0].play()


# ==========================================
# МУЗЫКАЛЬНАЯ СИСТЕМА
# ==========================================

func _setup_music_system():
	#Настраиваем первый музыкальный плеер
	add_child(music_player_a)
	music_player_a.bus = "Music"
	music_player_a.volume_db = -80 #начинаем с приглушенной музыки
	#Настраиваем второй музыкальный плеер
	add_child(music_player_b)
	music_player_b.bus = "Music"
	music_player_b.volume_db = -80 #начинаем с приглушенной музыки
	
	active_music_player = music_player_a


func play_music(new_track: AudioStream, fade_time: float = 1.0):
	var target_player = music_player_b if active_music_player == music_player_a else music_player_a
	if active_music_player.stream == new_track and active_music_player.playing:
		return # Если уже играет нужная музыка, ничего не делаем
	target_player.stream = new_track
	target_player.volume_db = -80
	target_player.play()
	var tween = create_tween()
	tween.tween_property(target_player, "volume_db", 0, fade_time)
	tween.parallel().tween_property(active_music_player, "volume_db", -80, fade_time)
	active_music_player = target_player

func play_hover(): #Публичные функции для вызова из других скриптов
	_play_from_pool(hover_sound_players)

func play_click(): #Публичные функции для вызова из других скриптов
	_play_from_pool(click_sound_players)

func play_game_over(): #Публичные функции для вызова из других скриптов
	_play_from_pool(game_over_sound_players)

func play_stage_clear(): #Публичные функции для вызова из других скриптов
	_play_from_pool(stage_clear_sound_players)

func play_pause_in():
	_play_from_pool(pause_in_sound_players)

func play_pause_out():
	_play_from_pool(pause_out_sound_players)
	
func play_player_shoot():
	_play_random_from_pool(player_shoot_sound_players, player_shoot_sounds)

func play_enemy_tier1_shoot():
	_play_random_from_pool(enemy_tier1_shoot_sound_players, enemy_tier1_shoot_sounds)

func play_regular_explosion():
	_play_random_from_pool(regular_explosion_sound_players, regular_explosion_sounds)


