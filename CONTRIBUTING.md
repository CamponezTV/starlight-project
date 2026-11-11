# Desenvolvimento

## Estrutura

Organizada por funcionalidade: cada pasta guarda cena, script e arte de uma coisa.

```
menu/        menu principal: continuar, novo jogo e capítulos
main/        jogo: carrega a fase, troca de sala, morte, checkpoint e recomeço
story/       StoryStep (um passo da campanha)
cutscenes/   cutscenes (uma pasta por cena) e seus fundos
dialogue/    caixa de diálogo e personagens que falam (Speaker)
characters/  bustos dos personagens das cutscenes (busts/)
player/      Jupiter: física, animações, rastro do dash, voz
companion/   estrela-guia
levels/      fases, salas (RoomZone), tilesets, fundos e enfeites do terreno
entities/    objetos de fase: estrela, cristal, estrela adormecida, saída, dica,
             rocha frágil, orbe de voz, barreira de palavras, chefe Sophie
effects/     efeitos descartáveis (explosão, poeira, estilhaços) e a vinheta
music/       trilhas (loops)
camera/      câmera
ui/          HUD, pausa, legendas, fonte e Theme
autoload/    App, Stars (vida), Music, Transition (fade), Story (campanha)
shared/      recursos compartilhados
tests/       testes (GUT)
addons/gut/  GUT (MIT)
```

- `Level` conecta os objetos de `Entities` e repassa os eventos deles.
- `main.gd` acompanha em qual sala o Jupiter está (câmera e renascimento) e decide as consequências (perder estrela, checkpoint, recomeço).
- O Jupiter não conhece a fase. Morre quando a `Hurtbox` toca a camada `hazards`.
- `Story` decide o que vem depois. Fases terminam com `Story.advance()` (saída ou chefe derrotado); cutscenes, quando o roteiro acaba.

| Camada de física | Nome | Conteúdo |
|---|---|---|
| 1 | world | rocha |
| 2 | player | Jupiter |
| 3 | hazards | espinhos, palavras da Sophie |

## Fases e salas

```
Level01 (Node2D, levels/level.gd)
├── Backdrop         cave_backdrop.tscn: fundo em camadas
├── Terrain          TileMapLayer: rocha
│   └── Decor        terrain_decor.tscn: enfeites automáticos
├── Hazards          TileMapLayer: espinhos
├── Spawn            Marker2D: início da fase
├── Rooms            salas (RoomZone), cada uma com Marker2D de renascimento
├── Entities         objetos da fase
└── Hints            dicas escritas no cenário (HintSign)
```

- **Salas (`RoomZone`):** retângulos que limitam a câmera, desenhados em azul no editor. Ao entrar numa sala, a câmera desliza para os limites dela e o renascimento vai para o `Marker2D` da sala mais perto de onde o Jupiter entrou. Cada sala precisa ter pelo menos o tamanho da tela (320×180) e não pode sobrepor outra.
- **Queda:** sair de uma sala por baixo sem cair em outra sala mata.
- **Rocha:** `Terrain` → aba TileMap → Terrenos → "Rocha". O autotile escolhe bordas e variações sozinho. Pinte também um anel de rocha por fora da fase, para as bordas não ganharem contorno.
- **Espinhos:** `Hazards`, com os 4 tiles da linha 2 do atlas (um por direção).
- **Fundo (`Backdrop`):** instância de `levels/backgrounds/cave_backdrop.tscn`. Fica em CanvasLayers próprias, então a escuridão (`ambient_color`) e as luzes da fase não o afetam. `tint` no Inspetor colore o fundo inteiro; cada fase usa o seu.
- **Enfeites (`Terrain/Decor`):** instância de `levels/decor/terrain_decor.tscn`, sempre filha da TileMapLayer do terreno. Sorteia musgo, cristais, cogumelos, raízes e brotos pela posição de cada bloco, então o resultado é sempre o mesmo. Pinte a rocha e os enfeites aparecem ao rodar o jogo (não aparecem no editor). As chances e o atlas (`texture`) ficam no Inspetor.
- **Objetos:** arraste as cenas de `entities/` para `Entities`. A origem fica nos pés, então encaixe no topo de um bloco.
- **Dicas:** arraste `entities/hint_sign/hint_sign.tscn` para `Hints` e escreva o texto no Inspetor. Ela aparece quando o Jupiter entra na área. Mantenha a dica a pelo menos 8 blocos da borda da sala para o texto não ser cortado.
- **Mensagens:** `intro_message` e `end_message` no nó raiz da fase.
- **Nova fase:** duplique uma fase existente e limpe o conteúdo. Depois adicione um `LevelInfo` em `levels` no `menu/menu.tscn`.
- **Novo objeto:** cena com raiz `Area2D` cujo script estende `RoomEntity`, com máscara na camada `player`.

## Campanha e cutscenes

- **Ordem da campanha:** `autoload/story.tscn` → Inspetor → `steps`. Cada passo (`StoryStep`) tem título, tipo (`CUTSCENE` ou `LEVEL`) e cena. O menu lista os passos sozinho.
- **Progresso:** o passo atual fica salvo em `user://progress.cfg` ("Continuar" no menu).
- **Nova cutscene:** cena com raiz `Node2D` cujo script estende `Cutscene`, com uma `DialogueBox` (`dialogue/dialogue_box.tscn`) e uma `Caption` (`ui/caption.tscn`) como filhas.
- **Planos:** cada filho de `Shots` é um plano (um `Node2D` com a arte, os bustos e os efeitos). `cut_to(plano)` mostra só aquele. Tudo na resolução do jogo (320×180); a arte dos planos abertos tem 352 px de largura para o `pan`.
- **Bustos:** instancie `characters/busts/*.tscn` no plano, em y = 180 (a origem fica embaixo, no meio). Dois personagens: x = 92 e x = 228, o da direita com `flip_h`. Troque a expressão com `pose`; as de cada um estão no Inspetor (`poses`). Cada expressão tem 3 quadros na folha: normal, piscando e falando.
- **Luz do ambiente:** cada busto tem `tint` (a cor que banha o personagem) e `rim` (a luz de contorno, do lado para onde ele olha). Use os mesmos valores para todos os bustos de um plano.
- **Profundidade:** num plano aberto, um filho chamado `Fg` (primeiro plano) ou `Clouds` desliza em outra velocidade durante o `pan`.
- **Quem mexe a boca:** no `_ready` da cutscene, `cast = {SPEAKER: busto}`.
- **Narrador:** `say(null, "(...)")`. É a voz que diz o que o Jupiter evita pensar.
- **Falas:** no máximo duas linhas na caixa (um teste confere).
- Escreva o roteiro em `_run()`:

```gdscript
func _run() -> void:
	Transition.fade_out(0.0)
	await show_caption("Seis anos depois", 3.0)
	Transition.fade_in(2.0)
	await say(JUPITER, "Vovô...")
	end_conversation()
	await cut_to(_close, 0.5)
	_jupiter.pose = "sad"
	await say(null, "(Você prometeu que não ia ter pressa.)")
```

- **Passos disponíveis:** `say`, `end_conversation`, `wait`, `show_caption`, `move`, `cut_to`, `pan`, `wait_for_player` e `Transition.fade_in/out`.
- **Fim da cena:** ao terminar `_run()`, a campanha segue. Esc pula.
- **Quem fala:** um `Speaker` (`dialogue/speakers/*.tres`) com nome, cor e tom de voz. `null` = narração.
- **Diálogo no alto da tela:** marque `at_top` na `DialogueBox` quando os personagens ficam embaixo.
- **Cutscene jogável:** coloque um `player.tscn` na cena e ligue/desligue `player.controllable`. Sem controle, `scripted_move_x` faz o Jupiter andar sozinho.

## Mecânicas da Fase 2

- **Rocha frágil** (`CrumbleBlock`): um bloco 8×8. Arraste para `Entities` com a origem na base da célula. Ajuste `crack_time` e `return_time` no Inspetor.
- **Orbe de voz** (`VoiceOrb`): dá `has_voice` ao Jupiter. Com `respawns`, volta depois do `RespawnTimer`.
- **Barreira de palavras** (`WordBarrier`): 8×32. Quebra com dash + voz e gasta a voz. Volta no reset da fase.
- **Chefe Sophie** (`SophieBoss`): aponte `arena` para a `RoomZone` da luta e posicione os `Marker2D` de `OrbSpots` (filhos editáveis). Ritmo e dificuldade ficam nas constantes por fase no topo do script.

## Arte

Para trocar, substitua os PNGs mantendo o tamanho dos quadros.

| Arquivo | Conteúdo |
|---|---|
| `player/jupiter.png` | 16 quadros 12×16: parado (0-1), piscada (2), corrida (3-8), pulo (9), topo do pulo (10), queda (11-12), parede (13), dash (14), pouso (15). O broche é **magenta puro** (#ff00ff): o shader troca pela cor de aceso/apagado |
| `player/jupiter_frames.tres` | animações (SpriteFrames), com duração por quadro |
| `levels/tilesets/cave_tiles.png` | 8×8: linhas 0, 1 e 3 = rocha (base e variações), linha 2 = espinhos. Em cada linha de rocha, a coluna diz quais lados estão expostos: some 1 (cima), 2 (direita), 4 (baixo) e 8 (esquerda) |
| `levels/backgrounds/cave_*.png` | camadas do fundo da caverna, 320×180. Todas repetem nos dois eixos: céu, brilhos, colunas distantes e colunas próximas |
| `levels/backgrounds/light_shaft.png` | feixe de luz do fundo (só o alfa importa; a cor vem do shader) |
| `levels/backgrounds/night_sky.png`, `mountain_far.png` | céu e serras da montanha e do menu (repetem a cada 320 px) |
| `levels/tilesets/*_decor.png` | enfeites do terreno, células 8×8: linha 0 = tufos, cogumelo e flor; linha 1 = cristais e pedras; linha 2 = pendurados; linha 3 = laterais (desenhados para uma parede à esquerda) |
| `ui/fonts/starlight_pixel.ttf` | fonte do jogo: 1 pixel por ponto em tamanho 8 (use 8 ou 16). Importada sem antialiasing e sem hinting |
| `companion/star.png` | estrela-guia, 4 quadros 16×16 |
| `entities/checkpoint/star_beacon.png` | estrela adormecida, 2 quadros 16×16 (apagada, acesa) |
| `entities/*/*.png` | estrela (4 quadros), cristal (2 brilhos + usado), feixe da saída |
| `ui/hud_star_*.png` | ícones de vida |
| `characters/busts/*.png` | bustos 128×128, 3 quadros por expressão, na ordem de `poses` |
| `cutscenes/art/*.png` | planos das cutscenes (`*_wide` abertos, `*_back` fundos dos bustos), moldura e detalhes |
| `levels/tilesets/mountain_tiles.png` | mesmo layout do `cave_tiles.png`, recolorido |
| `entities/sophie_boss/sophie_shadow.png` | 4 quadros 32×40: parada (2), gritando, atordoada |

## Áudio

- Buses: `Music` (-6 dB) e `SFX`. Todo `AudioStreamPlayer` usa um dos dois.
- Os efeitos ficam junto de quem os toca (`player/sounds/`, `entities/*/`, `menu/sounds/`, `main/sounds/`, `dialogue/`, `cutscenes/*/`). Foram sintetizados na pentatônica de Ré maior, com timbre de sino e eco longo.
- **Trilhas** (`music/`): loops sem emenda, todas variações do tema "A Promessa" (`promise`). O bus `Music` tem reverb e abertura estéreo, então as faixas são mono. No import, `Loop Mode` = Forward. Toque com `Music.play(stream)`, que faz crossfade e não reinicia a faixa que já está tocando. Fases usam `music` no nó raiz; cutscenes, `music` no Inspetor.
- **Música do menu:** coloque o arquivo em `menu/music/menu_theme.mp3` (ou mude `music_path` no Menu). Ela toca em loop. Sem o arquivo, toca `fallback_music`. A pasta `menu/music/` fica fora do Git porque a música é de terceiros.
- **Para fechar o jogo, use `App.quit()`**, nunca `get_tree().quit()`. O App espera o áudio ser liberado antes de sair. O X da janela já passa por ele.

## Testes

Painel **GUT** no editor → **Run All**, ou:

```
godot --headless -s res://addons/gut/gut_cmdln.gd
```

Os robôs de `tests/integration/test_level_0*_playthrough.gd` jogam cada desafio das fases (base em `tests/support/playthrough_test.gd`). Rode depois de mexer numa fase ou nos valores do `Player`: se um robô falhar, o desafio ficou impossível ou bem mais difícil. `test_cutscenes.gd` roda cada cutscene até o fim com o tempo acelerado.

## Convenções

- [Guia de estilo do GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
- Código em inglês, comentários e textos do jogo em português.
- Tipagem estática em tudo.
- Sem números mágicos: use constantes ou `@export`.
- A cena monta (colisão, sprite, luz, animação). O script só tem lógica.
- Membros privados com `_`.
- `Area2D` que detecta tiles precisa de `monitorable = true`.
- Efeitos parados (rastro, partículas) usam `physics_interpolation_mode = Off`. Sem isso, aparecem "voando" da origem no primeiro quadro.
- O jogo renderiza em `canvas_items`, com filtro nearest pra pixel art. As fontes são desenhadas em 8px e ampliadas (sem oversampling), pra manter o visual pixelado.
- Brilho de um objeto: um `Sprite2D` com `shared/light_soft.tres` e o material `shared/additive.tres`, filho do sprite (assim some junto com ele). A `PointLight2D` ilumina o que está em volta; o sprite aditivo é o halo.
- Atualize o Patch Notes do README a cada versão.
