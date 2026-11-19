# Desenvolvimento

## Estrutura

Organizada por funcionalidade: cada pasta guarda cena, script e arte de uma coisa.

```
menu/        tela de título: páginas, logo (art/) e sons
locale/      traduções (en.po)
tools/i18n/  catálogo de textos e o atualizador do en.po
main/        jogo: carrega a fase, troca de sala, morte, checkpoint e recomeço
story/       StoryStep (um passo da campanha)
cutscenes/   cutscenes (uma pasta por cena) e seus fundos
dialogue/    caixa de diálogo e personagens que falam (Speaker)
characters/  bustos dos personagens das cutscenes (busts/)
player/      Jupiter: física, animações, rastro do dash, voz
companion/   estrela-guia
levels/      fases, salas (RoomZone), tilesets, fundos e enfeites do terreno
entities/    objetos de fase: estrela perdida, cristal, estrela adormecida, portal,
             broche, dica, rocha frágil, orbe de voz, barreira de palavras, chefe Sophie
effects/     efeitos descartáveis (explosão, poeira, estilhaços) e a vinheta
music/       trilhas (loops)
camera/      câmera
ui/          HUD, pausa, holofote de habilidade, resumo da fase, legendas, fonte e Theme
autoload/    App, Settings (configurações), Music, Transition (fade),
             Story (campanha e escolhas), Presence (status no Discord)
shared/      recursos compartilhados
tests/       testes (GUT)
addons/gut/  GUT (MIT)
```

- `Level` conecta os objetos de `Entities` e repassa os eventos deles.
- `main.gd` acompanha em qual sala o Jupiter está (câmera e renascimento) e decide as consequências (morte, checkpoint, holofote de habilidade, fim de fase).
- Não há vidas. Quando o Jupiter morre, o `Main` chama `Level.reset_entities()` (cada objeto volta ao estado inicial pelo seu `reset()`) e ele renasce no último ponto.
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
- **Objetos largos:** aumente `decor_clearance` (blocos para cada lado) para os enfeites do chão não nascerem embaixo deles.
- **Dicas:** arraste `entities/hint_sign/hint_sign.tscn` para `Hints` e escreva o texto no Inspetor. Ela aparece quando o Jupiter entra na área. Mantenha a dica a pelo menos 8 blocos da borda da sala para o texto não ser cortado, e a pelo menos 15 blocos de outra dica (um teste falha se duas áreas se encostam).
- **Mensagens:** `intro_message` (ao começar) e `end_message` (no resumo do fim) no nó raiz da fase.
- **Nova fase:** duplique uma fase existente e limpe o conteúdo. Depois adicione um passo em `steps` (`autoload/story.tscn`); o menu lista os capítulos sozinho.
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
- **Orbe de voz** (`VoiceOrb`): dá `has_voice` ao Jupiter. Pega, encolhe num estouro de faíscas (`effects/voice_burst.tscn`, com um clarão de luz) e a aura do Jupiter acende grande. Com `respawns`, volta depois do `RespawnTimer`. Com um `Skill` em `skill`, a primeira coleta da visita abre o holofote (só a primeira orbe da Fase 2 tem).
- **Barreira de palavras** (`WordBarrier`): 8×32. Quebra com dash + voz e gasta a voz. Volta no reset da fase.
- **Chefe Sophie** (`SophieBoss`): aponte `arena` para a `RoomZone` da luta e posicione os `Marker2D` de `OrbSpots` (filhos editáveis). Ritmo e dificuldade ficam nas constantes por fase no topo do script. `phase_music` tem uma trilha por fase: no golpe, a próxima cresce durante o atordoamento (`MUSIC_FADE_IN`) enquanto a antiga some mais rápido (`MUSIC_FADE_OUT`), e o reset da luta volta do mesmo jeito para a primeira.
- **Perigos que guardam o Jupiter** (`_player_inside`, como a Sophie e o Sussurro): só ficam sabendo que ele saiu no passo de física seguinte. Por isso o `Player` não morre nos `SPAWN_GUARD_FRAMES` quadros depois de renascer; sem isso, o toque antigo mataria de novo. Nunca ponha um ponto de renascimento dentro de um perigo: nesses quadros ele não mata.
  - **Falas:** `INTRO_TEXT`, `TAUNT_TEXTS`, `KILL_TEXTS`, `RETORT_TEXTS` (uma por ponto de vida) e as listas de palavras arremessadas. A colisão de cada palavra tem o tamanho do texto: palavras da chuva e do anel com até 5 letras, frases rasteiras com até 27 (um teste confere).
  - **Olhos:** `Sprite/Eyes` usa `sophie_eyes.png` (mesmos quadros do corpo) sem sombreamento, para aparecer no escuro.
  - **Camadas:** `Voices` (falas, fora do escuro da fase, acompanha a câmera) e `Dread` (o escuro pulsando e o clarão vermelho dos golpes).

## Estrelas perdidas

- **`StarPickup`:** arraste para `Entities` e dê um nome que diga onde ela está (ex.: `EstrelaPoco`).
- **Regra:** tocada, segue o Jupiter; fica guardada depois de `SAFE_GROUND_TIME` no chão; volta para o lugar se ele morrer antes. Coloque cada uma num desvio do caminho, com chão firme só depois do desafio.
- **Por visita:** nada é salvo. Cada vez que a fase começa, todas as estrelas estão no lugar e o contador está em 0; a `Level` guarda as da visita. `Level.star_total()` e `Level.stars_found()` alimentam o contador do HUD e o resumo.
- **Estrela de conversa:** um `Encounter` com `offers_star()` entra na conta; o sinal `gifted` a guarda. Como a decisão fica salva e a conversa não se repete, `has_given_star()` diz se ela já foi dada: a fase começa com ela guardada. Quem perde a estrela numa decisão devolve `false` em `offers_star()` e ela sai da conta.

## Habilidades

- **Dash:** `Player.dash_unlocked`. Uma fase com `starts_with_dash` desligado começa sem ele; o `DashUnlock` (o broche no altar) ensina e a fase avisa com o sinal `skill_unlocked(skill)`.
- **Voz:** não é permanente (cada orbe dá uma carga), mas a primeira orbe da Fase 2 a apresenta no holofote pelo mesmo sinal `skill_unlocked`.
- **Holofote** (`SkillShowcase`, `ui/skill_showcase.tscn`): o `Main` pausa o jogo e chama `present(skill, posição na tela)`. O texto vem de um recurso `Skill` (`title`, `description`, `controls`), editado no Inspetor de quem ensina a habilidade.

## Fim de fase

- **Portal** (`RoomExit`): avisa com `reached`. O `Main` tira o controle, chama `absorb(jupiter)` e abre o resumo.
- **Resumo** (`LevelComplete`, `ui/level_complete.tscn`): recebe um `LevelSummary` (título, frase, estrelas, quedas, tempo) e espera o jogador confirmar antes de `Story.advance()`. Fases de chefe não têm portal: o resumo abre direto.
- **Shaders de tela** (`ui/spotlight.gdshader`, `ui/iris.gdshader`): o `modulate` do nó não vale neles; use os parâmetros `amount` e `opacity`.
- **Enfeites** (`TerrainDecor`): não nascem nas células em volta dos filhos de `Entities`, `Hints` e `Platforms`.

## A montanha (prólogo jogável)

- A cena é `cutscenes/mountain/mountain.tscn`: terreno em `mountain_terrain.tscn`, objetos em `Props` (atrás do Jupiter) e `FrontProps` (na frente), arte em `cutscenes/mountain/art/`.
- **Lembranças** (`MemorySpot`): filhos de `Memories`. Na primeira passagem do Jupiter, o `text` aparece em `Thoughts/Label`. Cada texto precisa caber em duas linhas (há um teste).
- **Habilidades:** `Player.dash_unlocked` e `Player.wall_moves_unlocked` são desligados no `_ready` da cena.
- **Objetos:** cada um fica com o pé inteiro em chão plano, sem encostar em outro. Atrás do Jupiter só entra o que faz sentido ele passar na frente (árvore, casa, poste, banco); na frente, só coisa baixa. Um teste falha se algum flutuar ou ficar enterrado.
- **Camadas:** `Town`, `Ridge` e `Mist` são `Parallax2D`. Com `scroll_scale.y` menor que 1, a camada desce na tela conforme a câmera sobe.

## Conversas e escolhas

- **Escolhas** (`ChoiceBox`, `dialogue/choice_box.tscn`): coloque na cutscene ao lado da `DialogueBox` (mesmo `at_top`). No roteiro: `var picked := await choose(["Sim.", "Não."])`. A última fala fica na tela enquanto o jogador decide.
- **Memória** (`Story.remember(key, value)` / `Story.recall(key)`): o que o jogador decidiu, salvo junto do progresso. `Story.start(0)` (jogo novo) esquece tudo.
- **Conversa dentro da fase** (`Encounter`): objeto de `Entities` com uma cutscene em `scene`. Com o Jupiter na área, Cima pede a conversa; o `Main` pausa o jogo, toca a cena por cima da fase e chama `conclude()` no fim. A cena não pode ter `Camera2D`. Subclasses sobrescrevem `is_available()` e `_on_concluded()`; o sinal `gifted` vale uma estrela (veja Estrelas perdidas).
- **Diana** (`DianaHut` + `cutscenes/diana`): a decisão fica em `DianaTalk.CHOICE_KEY`. Uma conversa nova segue o mesmo par: um `Encounter` na fase e uma cutscene que chama `Story.remember`.

## Mecânicas da Fase 3

- **Broto-mola** (`Sprout`): em `Entities`. Ajuste `bounce_speed` no Inspetor.
- **Sussurro** (`Whisper`): em `Entities`. Patrulha de onde foi colocado até `travel`, a `speed` px/s. `phase` (0 a 1) diz em que ponto do vai-e-volta ele começa: sussurros vizinhos com fases diferentes formam uma onda (a sala "O Coro" da Fase 2).
- **Plataforma móvel** (`MovingPlatform`): em `Platforms` (não em `Entities`, porque é um corpo sólido). Vai até `travel` e volta a cada `period` segundos.
- **Tremor de câmera:** um objeto da fase pode pedir com o sinal `shake_requested` do `Level`.

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
| `icon.png` | ícone do jogo, 256×256 (desenhado em 128 e ampliado 2×): a estrela-guia no céu noturno, num quadrado arredondado |
| `promo/banner.png` | banner de apresentação, 920×430 (desenhado em 460×215): logo, a estrela, a colina e o Jupiter. A pasta tem `.gdignore`: o Godot não importa |
| `companion/star.png` | estrela-guia, 4 quadros 16×16 |
| `entities/checkpoint/star_beacon.png` | estrela adormecida, 2 quadros 16×16 (apagada, acesa) |
| `entities/star_pickup/star_pickup.png` | estrela perdida, 4 quadros 16×16 |
| `entities/dash_unlock/*.png` | broche (4 quadros 16×16) e altar (32×20) |
| `entities/room_exit/*.png` | arco do portal (48×56), máscara do véu (mesmo tamanho) e o feixe de luz acima dele |
| `entities/dash_crystal/dash_crystal.png` | cristal: 2 brilhos + usado |
| `ui/hud_star_*.png` | ícone de estrela, cheia e vazia (contador e resumo da fase) |
| `characters/busts/*.png` | bustos 128×128, 3 quadros por expressão, na ordem de `poses` |
| `cutscenes/art/*.png` | planos das cutscenes (`*_wide` abertos, `*_back` fundos dos bustos), moldura e detalhes |
| `levels/tilesets/mountain_tiles.png` | mesmo layout do `cave_tiles.png`, recolorido |
| `entities/sophie_boss/sophie_shadow.png` | 7 quadros 96×112: parada (0-3), gritando (4-5), atordoada (6). O pé (origem do nó) fica 84 px abaixo do topo; o resto é a barra se desfazendo |
| `entities/sophie_boss/sophie_eyes.png` | olhos, dentes e goela, nos mesmos 7 quadros |
| `entities/sophie_boss/hand.png` | a mão, 2 quadros 24×28: aberta e punho |

## Áudio

- Buses: `Music` (-6 dB) e `SFX`. Todo `AudioStreamPlayer` usa um dos dois.
- Os efeitos ficam junto de quem os toca (`player/sounds/`, `entities/*/`, `menu/sounds/`, `main/sounds/`, `dialogue/`, `cutscenes/*/`). Foram sintetizados na pentatônica de Ré maior, com timbre de sino e eco longo.
- **Trilhas** (`music/`): loops sem emenda, todas variações do tema "A Promessa" (`promise`). O bus `Music` tem reverb e abertura estéreo, então as faixas são mono. No import, `Loop Mode` = Forward. Toque com `Music.play(stream)`, que faz crossfade (de potência constante: o volume não afunda no meio; `fade_out` deixa a antiga sumir num tempo diferente) e não reinicia a faixa que já está tocando. Fases usam `music` no nó raiz; cutscenes, `music` no Inspetor. A luta com a Sophie tem quatro (`sophie_1.wav` a `sophie_4.wav`), uma por fase, todas "A Promessa" em Ré menor com o mesmo número de compassos: 80, 92, 104 e 116 BPM, cada uma mais cheia que a anterior. A primeira também é a `music` da fase.
- **Música do menu:** `music/menu_promise.wav` ("A Promessa" à noite), em `music` no Inspetor do Menu. O jogo só leva música original. A pasta `menu/music/` continua fora do Git; se houver música de terceiros nela, tire antes de exportar uma build, senão ela vai junto.
- **Para fechar o jogo, use `App.quit()`**, nunca `get_tree().quit()`. O App espera o áudio ser liberado antes de sair. O X da janela já passa por ele.

## Menu e configurações

- **Tela de título** (`menu/menu.tscn`): o fundo é o plano aberto da colina (`Scene`), o `Shade` escurece a esquerda para o texto ler bem e o `Dim` escurece tudo nas subpáginas. As páginas ficam em `Content/Pages` (`Main`, `Chapters`, `Settings`, `Confirm`); só uma aparece por vez.
- **Opções de menu:** `Button` com `theme_type_variation = MenuItem` (texto sem caixa, dourado em foco, espaço à esquerda para a estrela-cursor).
- **Capítulos (dev):** saem de `Story.steps` sozinhos, mais os `dev_steps` (sala de teste, finais). O botão fica escondido; o código secreto (`SecretCode`: cima, cima, baixo, baixo, esquerda, direita, esquerda, direita, B, A) libera. `Menu.dev_unlocked` é estático, então vale até o jogo fechar.
- **Fim do pré-alpha:** o último passo da campanha é `cutscenes/credits` (agradecimento e créditos). Passos novos entram antes dele.
- **Configurações** (autoload `Settings`): `set_language`, `set_volume(bus, 0..1)`, `set_auto_advance`, `set_fullscreen`, `set_window_scale`. Cada uma aplica, salva em `user://settings.cfg` e emite `changed`. O volume de cada bus no `default_bus_layout.tres` é o 100%.
- **Resolução:** o jogo é desenhado em 320x180 (o viewport) e escalado só por números inteiros (`stretch/scale_mode = integer`), para o pixel art ficar nítido. Na janela, `window_scale` escolhe a escala (de 2x até a maior que cabe na tela, 4x = 1280x720 por padrão); na tela cheia, o Godot usa a maior que cabe no monitor e completa com bordas pretas. Com o jogo embutido na aba Game do editor (o padrão do F5), a janela é do editor: tela cheia e tamanho não mudam nada ali. Para testar, desligue o "Embed Game on Next Play" no menu da aba Game. A linha "Tela" do painel (`cycle_display`) passa pelas janelas e termina na tela cheia.
- **Painel** (`ui/settings_panel.tscn`): usado no menu e na pausa. Cada linha é um `OptionRow` (esquerda e direita trocam o valor, o sinal `stepped` diz para que lado). Esc ou Voltar emitem `closed`.
- **Texto automático:** `DialogueBox` espera `AUTO_ADVANCE_BASE` + `AUTO_ADVANCE_PER_LETTER` por letra depois de a fala aparecer inteira.

## Discord

- **Presence** (autoload) monta o status e entrega ao `DiscordRichPresence` (addon em `addons/discord_rich_presence/`, MIT). Percebe sozinho cada cena que entra como cena principal (menu, fase ou cutscene) e atualiza também quando o idioma muda.
- **Sem citar classes de cena no autoload:** ele reconhece as cenas pelo caminho do menu, por `level_scene` e por `say`. Referenciar `Menu`, `Main` ou `Cutscene` num autoload prende scripts na memória ao fechar o jogo.
- **App do Discord:** o ID fica em `Presence.APP_ID` (não é segredo).
- **Imagem:** o status usa só o ícone do jogo (chave `icon`). `godot --headless -s res://tools/discord/make_image.gd` exporta `icon.png` em 1024 px para `tools/discord/images/`. Envie em Rich Presence → Art Assets sem renomear. Mudou o ícone? Rode de novo e troque a imagem no portal.
- **Nunca mande texto vazio:** o Discord recusa o status inteiro. Um teste confere todos os passos.
- Sem Discord aberto, na web, no celular e nos testes (headless), o addon não faz nada.

## Traduções

- **O jogo é escrito em português**, e cada texto em português é a chave da tradução. O inglês fica em `locale/en.po`. Em português nada é traduzido (o `fallback` do projeto é `pt_BR`).
- **O que é traduzido:** falas e escolhas (`say`, `show_caption`, `choose`), qualquer `tr("...")`, constantes com nome terminado em `_TEXT` ou `_TEXTS`, e nas cenas as propriedades `text`, `title`, `description`, `controls`, `display_name`, `intro_message` e `end_message`. Labels e botões das cenas traduzem sozinhos; texto montado em código passa por `tr()` antes de formatar (`tr(CONTINUE_TEXT) % titulo`).
- **Texto novo:** escreva em português, rode `godot --headless -s res://tools/i18n/update_po.gd` e preencha os `msgstr` vazios do `en.po`. O teste `test_translations.gd` aponta texto sem tradução, tradução que sobrou e inglês que não cabe (falas, lembranças, palavras da Sophie, páginas do menu).
- **Idioma novo:** adicione o código em `Settings.LANGUAGES` e `LANGUAGE_NAMES`, crie `locale/<código>.po` (copie o `en.po` e troque o `Language`) e inclua em `internationalization/locale/translations` no `project.godot`.

## Testes

Painel **GUT** no editor → **Run All**, ou:

```
godot --headless -s res://addons/gut/gut_cmdln.gd
```

Os robôs de `tests/integration/test_level_0*_playthrough.gd` jogam cada desafio das fases (base em `tests/support/playthrough_test.gd`). Rode depois de mexer numa fase ou nos valores do `Player`: se um robô falhar, o desafio ficou impossível ou bem mais difícil, e ele diz em que célula parou. `run_bot` confirma sozinho um holofote no caminho. Salas de ritmo (sussurros, plataformas) são testadas várias vezes com esperas diferentes antes da largada: o teste exige uma fração mínima de largadas que passam, para o desafio ser apertado sem depender de um quadro exato. `test_cutscenes.gd` roda cada cutscene até o fim com o tempo acelerado. Testes que guardam escolhas usam `TestHelpers.use_test_save()` para não tocar no progresso de quem joga. As configurações dos testes vão para um arquivo próprio (`tests/support/pre_run.gd`), sempre em português e no padrão.

## Exportar

- **Presets** (`export_presets.cfg`), cada um com o jogo embutido num arquivo só: `Windows` (`builds/windows/Starlight.exe`), `Linux` (`builds/linux/Starlight.x86_64`) e `macOS` (`builds/macos/Starlight.zip`, um `.app` universal: Intel e Apple Silicon). Precisam dos export templates da mesma versão do editor (Editor > Manage Export Templates). Linha de comando: `godot --headless --export-release <preset> <arquivo>`.
- **Mac:** o app sai só com assinatura ad-hoc, sem notarização (isso exige a conta paga de desenvolvedor da Apple). O macOS bloqueia na primeira vez: botão direito no app > Abrir, ou `xattr -cr Starlight.app`. O ETC2/ASTC ligado no projeto é exigência do Godot para exportar para Apple Silicon; o pixel art não usa compressão de VRAM, então nada muda na imagem.
- **Linux:** o binário perde a permissão de execução se passar por um zip feito no Windows: `chmod +x Starlight.x86_64`.
- **O que fica de fora** (`exclude_filter`): a música de terceiros de `menu/music/` (sem licença para redistribuir), os testes, o GUT, `tools/`, `promo/` e capturas de tela. Pasta nova que não é do jogo entra nessa lista.
- **Logs dos jogadores:** o jogo grava `godot.log` (os 5 últimos ficam) em `app_userdata/Starlight/logs/`, dentro de `%APPDATA%Godot` no Windows, `~/.local/share/godot/` no Linux e `~/Library/Application Support/Godot/` no Mac. É o que pedir junto com um relato de bug.

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
