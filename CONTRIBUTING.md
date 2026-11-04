# Desenvolvimento

## Estrutura

Organizada por funcionalidade: cada pasta guarda cena, script e arte de uma coisa.

```
menu/        menu principal e seleção de fases
main/        jogo: carrega a sala, morte, checkpoint e recomeço
player/      Jupiter: física, visual, rastro do dash
companion/   estrela-guia
rooms/       salas, script base, tileset e fundos
entities/    objetos de sala: estrela, cristal, checkpoint, saída
effects/     efeitos descartáveis
camera/      câmera
ui/          HUD e Theme
autoload/    vida ("Stars") e ciclo do app ("App")
shared/      recursos compartilhados
tests/       testes (GUT)
addons/gut/  GUT (MIT)
```

- `Room` conecta os objetos de `Entities` e repassa os eventos deles.
- `main.gd` decide as consequências (perder estrela, checkpoint, recomeço).
- O Jupiter não conhece a sala. Morre quando a `Hurtbox` toca a camada `hazards`.

| Camada de física | Nome | Conteúdo |
|---|---|---|
| 1 | world | rocha |
| 2 | player | Jupiter |
| 3 | hazards | espinhos |

## Salas

```
Room01 (Node2D, rooms/room.gd)
├── Background   Parallax2D
├── Terrain      TileMapLayer: rocha
├── Hazards      TileMapLayer: espinhos
├── Spawn        Marker2D: início
└── Entities     objetos da sala
```

- **Rocha:** `Terrain` → aba TileMap → Terrenos → "Rocha".
- **Espinhos:** `Hazards`, com os 4 tiles da última linha do atlas.
- **Objetos:** arraste as cenas de `entities/` para `Entities`. A origem fica nos pés.
- **Nova sala:** duplique `room_01.tscn`, limpe o conteúdo e adicione um `LevelInfo` em `levels` no `menu/menu.tscn`.
- **Novo objeto:** cena com raiz `Area2D` cujo script estende `RoomEntity`, com máscara na camada `player`.

## Arte

Provisória. Para trocar, substitua os PNGs mantendo o tamanho dos quadros.

| Arquivo | Conteúdo |
|---|---|
| `player/jupiter.png` | 3 quadros 8×12: broche aceso, apagado, silhueta do dash |
| `rooms/tilesets/cave_tiles.png` | 8×8: linha 0 rocha, linha 1 variações, linha 2 espinhos |
| `entities/*/*.png` | objetos (cristal e telescópio com 2 quadros) |
| `companion/star.png`, `ui/hud_star_*.png` | estrela-guia e ícones de vida |

## Áudio

- Buses: `Music` (-6 dB) e `SFX`. Todo `AudioStreamPlayer` usa um dos dois.
- Os efeitos ficam junto de quem os toca (`player/sounds/`, `entities/*/`, `menu/sounds/`, `main/sounds/`). Foram sintetizados na pentatônica de Ré maior, com timbre de sino e eco longo.
- **Música do menu:** coloque o arquivo em `menu/music/menu_theme.ogg` (ou mude `music_path` no Menu). Ela toca em loop. Sem o arquivo, o menu fica em silêncio. A pasta `menu/music/` fica fora do Git porque a música é de terceiros.
- **Para fechar o jogo, use `App.quit()`**, nunca `get_tree().quit()`. O App espera o áudio ser liberado antes de sair. O X da janela já passa por ele.

## Testes

Painel **GUT** no editor → **Run All**, ou:

```
godot --headless -s res://addons/gut/gut_cmdln.gd
```

Rode depois de mexer nos valores do `Player`. Os testes conferem se a sala continua possível.

## Convenções

- [Guia de estilo do GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
- Código em inglês, comentários e textos do jogo em português.
- Tipagem estática em tudo.
- Sem números mágicos: use constantes ou `@export`.
- A cena monta (colisão, sprite, luz, animação). O script só tem lógica.
- Membros privados com `_`.
- `Area2D` que detecta tiles precisa de `monitorable = true`.
- Atualize o Patch Notes do README a cada versão.
