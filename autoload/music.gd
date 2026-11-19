extends Node
## Autoload "Music": a trilha do momento, no bus Music, com troca suave entre faixas.
## Pedir a faixa que já está tocando não reinicia nada (a música continua entre cenas).
## Dois players se revezam: um some enquanto o outro cresce. As curvas são de potência
## constante (seno e cosseno): no meio da troca, o volume não afunda.

const DEFAULT_FADE := 1.2
const BUS := &"Music"

var _players: Array[AudioStreamPlayer] = []
var _tweens: Array[Tween] = [null, null]
var _active := 0
var _is_on := false ## O player ativo está tocando ou crescendo (não sumindo).


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 2:
		var player := AudioStreamPlayer.new()
		player.bus = BUS
		add_child(player)
		_players.append(player)


## Troca para `stream` com crossfade: a nova cresce em `fade` segundos e a antiga some em
## `fade_out` (negativo = o mesmo `fade`). `null` para a música.
func play(stream: AudioStream, fade := DEFAULT_FADE, fade_out := -1.0) -> void:
	if stream == null:
		stop(fade)
		return
	if is_playing(stream):
		return
	_fade(_active, 0.0, fade if fade_out < 0.0 else fade_out)
	_active = 1 - _active
	var player := _players[_active]
	player.stream = stream
	player.volume_linear = 0.0
	player.play()
	_fade(_active, 1.0, fade)
	_is_on = true


## Para a música. Os dois players: no meio de uma troca, a faixa antiga ainda está sumindo.
func stop(fade := DEFAULT_FADE) -> void:
	for index in _players.size():
		_fade(index, 0.0, fade)
	_is_on = false


func is_playing(stream: AudioStream) -> bool:
	return _is_on and _players[_active].stream == stream


## A faixa atual, ou null se nada estiver tocando.
func current() -> AudioStream:
	return _players[_active].stream if _is_on else null


func _fade(index: int, target: float, duration: float) -> void:
	var player := _players[index]
	if _tweens[index] != null:
		_tweens[index].kill()
	_tweens[index] = null
	if duration <= 0.0:
		player.volume_linear = target
		if target == 0.0:
			player.stop()
		return
	var tween := create_tween()
	var curve := Tween.EASE_OUT if target > player.volume_linear else Tween.EASE_IN
	tween.tween_property(player, "volume_linear", target, duration).set_trans(Tween.TRANS_SINE).set_ease(curve)
	if target == 0.0:
		tween.tween_callback(player.stop)
	_tweens[index] = tween
