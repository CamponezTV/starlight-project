# Desenvolvimento

## Estrutura

Organizada por funcionalidade: cada pasta guarda cena, script e arte de uma coisa.

```
menu/        menu principal e seleção de fases
main/        jogo: carrega a fase, troca de sala, morte, checkpoint e recomeço
player/      Jupiter: física, animações, rastro do dash
companion/   estrela-guia
levels/      fases (level_01, test_room), salas (RoomZone), tileset e fundos
entities/    objetos de fase: estrela, cristal, estrela adormecida, saída, dica
effects/     efeitos descartáveis (explosão, poeira)
camera/      câmera
ui/          HUD e Theme
autoload/    vida ("Stars") e ciclo do app ("App")
shared/      recursos compartilhados
tests/       testes (GUT)
addons/gut/  GUT (MIT)
```

- `Level` conecta os objetos de `Entities` e repassa os eventos deles.
- `main.gd` acompanha em qual sala o Jupiter está (câmera e renascimento) e decide as consequências (perder estrela, checkpoint, recomeço).
- O Jupiter não conhece a fase. Morre quando a `Hurtbox` toca a camada `hazards`.

| Camada de física | Nome | Conteúdo |
|---|---|---|
| 1 | world | rocha |
| 2 | player | Jupiter |
| 3 | hazards | espinhos |

## Fases e salas

```
Level01 (Node2D, levels/level.gd)
├── Background       Parallax2D: luzes distantes
├── CaveSilhouettes  Parallax2D: estalactites em silhueta
├── Terrain          TileMapLayer: rocha
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
- **Objetos:** arraste as cenas de `entities/` para `Entities`. A origem fica nos pés, então encaixe no topo de um bloco.
- **Dicas:** arraste `entities/hint_sign/hint_sign.tscn` para `Hints` e escreva o texto no Inspetor. Ela aparece quando o Jupiter entra na área. Mantenha a dica a pelo menos 8 blocos da borda da sala para o texto não ser cortado.
- **Mensagens:** `intro_message` e `end_message` no nó raiz da fase.
- **Nova fase:** duplique uma fase existente e limpe o conteúdo. Depois adicione um `LevelInfo` em `levels` no `menu/menu.tscn`.
- **Novo objeto:** cena com raiz `Area2D` cujo script estende `RoomEntity`, com máscara na camada `player`.

## Arte

Provisória. Para trocar, substitua os PNGs mantendo o tamanho dos quadros.

| Arquivo | Conteúdo |
|---|---|
| `player/jupiter.png` | 16 quadros 12×16: parado (0-1), piscada (2), corrida (3-8), pulo (9), topo do pulo (10), queda (11-12), parede (13), dash (14), pouso (15). O broche é **magenta puro** (#ff00ff): o shader troca pela cor de aceso/apagado |
| `player/jupiter_frames.tres` | animações (SpriteFrames), com duração por quadro |
| `levels/tilesets/cave_tiles.png` | 8×8: linhas 0, 1 e 3 = rocha (base e variações), linha 2 = espinhos |
| `levels/backgrounds/*.png` | luzes distantes e silhuetas (repetem a cada 320 px) |
| `companion/star.png` | estrela-guia, 4 quadros 16×16 |
| `entities/checkpoint/star_beacon.png` | estrela adormecida, 2 quadros 16×16 (apagada, acesa) |
| `entities/*/*.png` | estrela (4 quadros), cristal (2 brilhos + usado), feixe da saída |
| `ui/hud_star_*.png` | ícones de vida |

## Áudio

- Buses: `Music` (-6 dB) e `SFX`. Todo `AudioStreamPlayer` usa um dos dois.
- Os efeitos ficam junto de quem os toca (`player/sounds/`, `entities/*/`, `menu/sounds/`, `main/sounds/`). Foram sintetizados na pentatônica de Ré maior, com timbre de sino e eco longo.
- **Música do menu:** coloque o arquivo em `menu/music/menu_theme.mp3` (ou mude `music_path` no Menu). Ela toca em loop. Sem o arquivo, o menu fica em silêncio. A pasta `menu/music/` fica fora do Git porque a música é de terceiros.
- **Para fechar o jogo, use `App.quit()`**, nunca `get_tree().quit()`. O App espera o áudio ser liberado antes de sair. O X da janela já passa por ele.

## Testes

Painel **GUT** no editor → **Run All**, ou:

```
godot --headless -s res://addons/gut/gut_cmdln.gd
```

Os robôs de `tests/integration/test_level_01_playthrough.gd` jogam cada desafio da Fase 1. Rode depois de mexer na fase ou nos valores do `Player`: se um robô falhar, o desafio ficou impossível ou bem mais difícil.

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
- Atualize o Patch Notes do README a cada versão.
