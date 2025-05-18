extends AudioStreamPlayer

const main_menu_music = preload("res://Assets/Music/main-menu-rainy-lofi-city-lofi-music-332746.mp3")

func _play_music(music: AudioStream, volume = 0):
	GameBgMusic.stop_music()
	if stream == music:
		return
	stream = music
	volume_db = volume
	play()	
	
func play_main_music():
	_play_music(main_menu_music)

func stop_music():
	stop()
