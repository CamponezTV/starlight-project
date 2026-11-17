extends GutHookScript
## Depois de todos os testes: para a música (sem isso, o áudio que ainda está tocando
## fica preso na memória quando o GUT encerra) e apaga as configurações dos testes.


func run() -> void:
	Music.stop(0.0)
	if Settings.save_path == TestHelpers.TEST_SETTINGS:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TestHelpers.TEST_SETTINGS))
