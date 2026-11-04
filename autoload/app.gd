extends Node
## Autoload "App": ciclo de vida do aplicativo.
## Fecha o jogo com segurança: libera a cena atual e espera o áudio ser solto antes de sair.
## Sem isso, fechar com um som tocando deixa o áudio preso na memória ao encerrar.

const FRAMES_TO_RELEASE_AUDIO := 2

var _is_quitting := false


func _ready() -> void:
	get_tree().auto_accept_quit = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()


func quit() -> void:
	if _is_quitting:
		return
	_is_quitting = true
	var scene := get_tree().current_scene
	if scene != null:
		scene.queue_free()
	for frame in FRAMES_TO_RELEASE_AUDIO:
		await get_tree().process_frame
	get_tree().quit()
