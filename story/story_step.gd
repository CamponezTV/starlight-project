class_name StoryStep
extends Resource
## Um passo da campanha: uma cutscene ou uma fase.

enum Kind {
	CUTSCENE, ## Cena própria, que chama Story.advance() quando termina.
	LEVEL, ## Fase (Level), carregada dentro do jogo (main.tscn).
}

@export var title := ""
@export var kind := Kind.LEVEL
@export var scene: PackedScene
