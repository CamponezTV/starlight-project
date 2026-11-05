extends GutHookScript
## Depois de todos os testes: para a música. Sem isso, o áudio que ainda está tocando
## fica preso na memória quando o GUT encerra.


func run() -> void:
	Music.stop(0.0)
