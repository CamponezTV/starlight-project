extends Node
## Autoload "Presence": o status do jogador no Discord ("Jogando Starlight", o capítulo
## atual, há quanto tempo e o ícone do jogo). Usa o addon DiscordRichPresence,
## que fala com o Discord aberto no computador; sem Discord (ou sem APP_ID), nada
## acontece e nada quebra.
## Percebe sozinho cada cena que entra como cena principal (menu, fase ou cutscene), seja
## pela campanha, pelos capítulos dev ou rodando a cena direto no editor (F6), e atualiza
## de novo quando o idioma muda.
## Reconhece as cenas pelo que elas têm (caminho do menu, level_scene, say), sem citar as
## classes Menu, Main e Cutscene: carregá-las num autoload prende scripts na memória ao
## fechar o jogo.

## Application ID do app "Starlight" no Discord Developer Portal (General Information).
## Vazio = desligado. Não é segredo: pode ficar no Git.
const APP_ID := "1572371769308881056"
## A imagem do status: o ícone do jogo, enviado em Rich Presence > Art Assets, no Developer
## Portal, com este nome (tools/discord/make_image.gd gera o arquivo).
const IMAGE_KEY := "icon"
const IMAGE_TITLE := "Starlight"

const MENU_TEXT := "No menu"
const CHAPTER_TEXT := "Capítulo %d: %s"
const PLAYING_TEXT := "Jogando"
const WATCHING_TEXT := "Numa lembrança"
const DEV_TEXT := "Modo dev"

var _discord: DiscordRichPresence
var _started := 0 ## Quando o jogo abriu (o Discord mostra o tempo desde então).
var _scene_path := "" ## Cena mostrada agora ("" = menu).
var _is_level := false
var _activity := {}


func _ready() -> void:
	_started = int(Time.get_unix_time_from_system())
	_discord = DiscordRichPresence.new()
	_discord.app_id = APP_ID
	add_child(_discord)
	get_tree().node_added.connect(_on_node_added)
	Settings.changed.connect(_refresh)
	_refresh()


## O status que está (ou estaria) no Discord agora.
func activity() -> Dictionary:
	return _activity


## Mostra o status de `scene`: o menu, uma fase (o jogo, com `level_scene`) ou uma cutscene.
func show_scene(scene: Node) -> void:
	_is_level = _is_game(scene)
	if scene.scene_file_path == Story.MENU_SCENE:
		_scene_path = ""
	elif _is_level:
		_scene_path = (scene.get(&"level_scene") as PackedScene).resource_path
	else:
		_scene_path = scene.scene_file_path
	_refresh()


## Só as cenas que viram cena principal (filhas da raiz). Uma conversa dentro de uma fase
## (Encounter) toca embaixo do Main e não troca o status.
func _on_node_added(node: Node) -> void:
	if node.get_parent() != get_tree().root:
		return
	if node.scene_file_path == Story.MENU_SCENE or _is_game(node) or node.has_method(&"say"):
		show_scene(node)


func _is_game(node: Node) -> bool:
	return node.get(&"level_scene") is PackedScene


func _refresh() -> void:
	_activity = {
		"details": tr(MENU_TEXT),
		"timestamps": {"start": _started},
		"assets": {"large_image": IMAGE_KEY, "large_text": IMAGE_TITLE},
	}
	if not _scene_path.is_empty():
		var index := _step_index(_scene_path)
		if index >= 0:
			var step := Story.steps[index]
			_activity["details"] = tr(CHAPTER_TEXT) % [index + 1, tr(step.title)]
			_is_level = step.kind == StoryStep.Kind.LEVEL
		else:
			_activity["details"] = tr(DEV_TEXT)
		_activity["state"] = tr(PLAYING_TEXT if _is_level else WATCHING_TEXT)
	_discord.set_activity(_activity)


## Posição da cena na campanha, ou -1 se ela não faz parte dela (sala de teste, finais).
func _step_index(scene_path: String) -> int:
	for i in Story.steps.size():
		if Story.steps[i].scene.resource_path == scene_path:
			return i
	return -1
