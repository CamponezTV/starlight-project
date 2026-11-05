extends Node
## Autoload "Story": a campanha em ordem (cutscenes e fases) e a troca entre elas.
## Os passos ficam em `steps`, no Inspetor de autoload/story.tscn. Fases rodam dentro
## do jogo (main/main.tscn); cutscenes são cenas próprias. Quem termina chama advance().
## Fora da campanha (fase aberta direto no editor ou pelo menu dev), advance() volta ao menu.
## O último passo começado fica salvo em `save_path`, para o "Continuar" do menu.

signal step_started(index: int)

const GAME_SCENE := "res://main/main.tscn"
const MENU_SCENE := "res://menu/menu.tscn"
const FADE_TIME := 0.5
const SAVE_SECTION := "story"
const SAVE_KEY := "step"

@export var steps: Array[StoryStep] = []

var save_path := "user://progress.cfg"

var _index := -1
var _is_changing := false


## Posição na campanha, ou -1 fora dela.
func current_index() -> int:
	return _index


## Começa a campanha no passo `index` (0 = novo jogo).
func start(index := 0) -> void:
	assert(index >= 0 and index < steps.size(), "passo %d fora da campanha" % index)
	_index = index
	save_progress(index)
	await _change_scene(instantiate_step(steps[index]))
	step_started.emit(index)


## Toca um passo avulso, fora da campanha (ex.: sala de teste).
func play_outside_campaign(step: StoryStep) -> void:
	_index = -1
	await _change_scene(instantiate_step(step))


## Vai para o próximo passo. Depois do último (ou fora da campanha), volta ao menu.
func advance() -> void:
	if _index < 0:
		back_to_menu()
	elif _index + 1 < steps.size():
		start(_index + 1)
	else:
		save_progress(-1)
		back_to_menu()


func back_to_menu() -> void:
	_index = -1
	_change_scene((load(MENU_SCENE) as PackedScene).instantiate())


## Passo salvo para continuar a campanha, ou -1 se não há o que continuar.
func saved_step() -> int:
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return -1
	var step: int = config.get_value(SAVE_SECTION, SAVE_KEY, -1)
	return step if step >= 0 and step < steps.size() else -1


## Guarda o passo atual (-1 apaga: campanha terminada).
func save_progress(index: int) -> void:
	var config := ConfigFile.new()
	config.set_value(SAVE_SECTION, SAVE_KEY, index)
	config.save(save_path)


## Monta a cena do passo: a própria cutscene, ou o jogo já com a fase.
func instantiate_step(step: StoryStep) -> Node:
	if step.kind == StoryStep.Kind.LEVEL:
		var game: Main = (load(GAME_SCENE) as PackedScene).instantiate()
		game.level_scene = step.scene
		return game
	return step.scene.instantiate()


## Escurece, troca a cena atual por `next` e clareia.
func _change_scene(next: Node) -> void:
	if _is_changing:
		next.free()
		return
	_is_changing = true
	await Transition.fade_out(FADE_TIME)
	var tree := get_tree()
	tree.paused = false
	var previous := tree.current_scene
	if previous != null:
		# Sai da árvore já (a nova cena não divide o quadro com ela) e é liberada no fim do quadro.
		tree.root.remove_child(previous)
		previous.queue_free()
	tree.root.add_child(next)
	tree.current_scene = next
	_is_changing = false
	Transition.fade_in(FADE_TIME)
