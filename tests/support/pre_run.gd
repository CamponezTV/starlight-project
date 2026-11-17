extends GutHookScript
## Antes de todos os testes: as configurações vão para um arquivo só dos testes e voltam
## ao padrão (português, volume cheio, texto manual). Assim os testes não dependem do
## que quem joga escolheu, nem mexem nisso.


func run() -> void:
	TestHelpers.use_test_settings()
