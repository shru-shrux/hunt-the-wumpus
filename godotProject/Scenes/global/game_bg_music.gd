extends AudioStreamPlayer

const game_music = preload("res://Assets/Music/background-fight-for-the-future-336841.mp3")

func _play_music(music: AudioStream, volume = 0):
	MainMenuBgMusic.stop_music()
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()	
	
func play_game_music():
	_play_music(game_music)

func stop_music():
	stop()
