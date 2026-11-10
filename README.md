# Starlight

Plataforma 2D em pixel art sobre Jupiter, seu avô e as estrelas. Feito em Godot 4.7.

**Como jogar:** abra o `project.godot` no [Godot 4.7](https://godotengine.org) (versão padrão) e aperte **F5**.

| Ação | Teclado | Controle |
|---|---|---|
| Mover | Setas / WASD | Analógico / D-pad |
| Pular | Espaço / C / J | A |
| Dash | X / K / Shift | X / B |
| Avançar diálogo | Espaço / Enter | A |
| Voltar ao checkpoint | R | Back |
| Pausa / Pular cutscene | Esc | — |

Documentação para desenvolvimento: [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Patch Notes

### v0.6.0 — Cara nova · 10/11/2026

**Novidades**
- **Caverna viva:** o fundo preto deu lugar a um cenário em camadas, com céu em degradê, brilhos distantes, colunas de rocha em dois planos, feixes de luz e poeira luminosa no ar. O fundo não escurece mais junto com a fase.
- **Rocha nova:** miolo escuro, bordas claras e musgo luminoso por cima. Espinhos de cristal bem mais visíveis.
- **O terreno se enfeita sozinho:** tufos de musgo, cogumelos e cristais que brilham, raízes e estalactites no teto e brotos nas paredes. Nada nasce onde há espinhos.
- **Cada fase com seu clima:** a Fase 2 puxa para o rosa e a arena da Sophie para o vermelho.
- **Objetos refeitos:** cristal de dash, estrela adormecida, rocha frágil, barreira de palavras, feixe da saída e estrela-guia. Todos ganharam brilho e faíscas.
- **Fonte própria:** letras em pixel art desenhadas para o jogo, com todos os acentos. O texto deixou de sair deformado.
- **Montanha:** céu com Via Láctea, três serras ao fundo, grama e flores no caminho.
- **Menu** com o céu da montanha, a estrela brilhando e poeira no ar.
- Vinheta suave nos cantos da tela durante as fases.

**Mudanças**
- A caverna ficou mais clara: dá para ver o cenário inteiro, e a luz da estrela continua destacando o que está perto.
- Jupiter com cores mais vivas (terno azul, cabelo castanho), para não sumir no fundo.
- A estrela-guia deixa um rastro de faíscas. A explosão ao morrer tem mais partículas e cor.
- As dicas no cenário ficaram um pouco mais largas.

**Técnico**
- `levels/backgrounds/cave_backdrop.tscn`: o fundo das fases numa cena só. `tint` muda a cor por fase.
- `levels/decor/terrain_decor.tscn`: filho do `Terrain`, sorteia os enfeites pela posição de cada bloco (sempre iguais).
- `ui/fonts/starlight_pixel.ttf` como fonte padrão do Theme.
- 79 testes automáticos. O teste do menu não depende mais do progresso salvo de quem roda.

**Problemas conhecidos**
- A música do menu não vem no repositório. Sem ela, o menu toca o tema da memória.

### v0.5.0 — Cutscenes de verdade · 05/11/2026

**Novidades**
- **Todas as cutscenes refeitas** em resolução dobrada (arte em 640×360 na mesma tela). Personagens com tamanho de gente: o avô é mais alto que o Jupiter, e o telescópio fica na altura de uma criança.
- **Personagens novos em alta:** Jupiter (14 anos, de terno), Jupiter criança, Jupiter de pijama (12 anos), o avô e a Sophie. Cada um tem várias poses: sentado, andando, ajoelhado, abraçando, apontando, chorando...
- **Personagens vivos:** piscam sozinhos e mexem a boca enquanto falam.
- **Câmera de cinema:** passeia pelo cenário e fecha o plano nos rostos durante as conversas.
- **Cenários novos:** colina com Via Láctea, árvore e vagalumes; quarto com estrelas no teto e luz da lua; cemitério na chuva; topo da montanha; caverna de cristais; galpão; e os cenários do final.
- **Prólogo, "O adeus" (nova):** o enterro do avô na chuva. Todos vão embora, as nuvens se abrem e Jupiter decide subir a montanha.
- **Prólogo, "A montanha":** no topo, a cena corta para um plano aberto do Jupiter diante do céu inteiro.
- **Memória, "A aranha" (nova, abre o Capítulo 2):** trancado no galpão, Jupiter vê uma aranha descer do teto e a sombra dela crescer na parede. O avô o encontra.
- **Finais do GDD (no menu dev):** o reencontro com o avô e a manhã no buraco.
- Sons novos: chuva, porta batendo, aranha andando e sirene. Música nova: "O adeus".

**Mudanças**
- Capítulos no menu em três colunas.
- As falas aparecem mesmo com a tela escura (vozes fora de cena).
- O título "Seis anos depois" passou para o enterro.

**Técnico**
- `Actor` (`cutscenes/actor.gd`): pose, piscada e boca automáticas. Cada personagem é uma cena em `characters/hd/`.
- Passos novos de roteiro: `walk`, `move_camera` e o `cast` (quem mexe a boca em cada fala).
- 78 testes automáticos. Todas as 9 cutscenes rodam até o fim nos testes.

### v0.4.0 — Capítulo 1: A Voz · 05/11/2026

**Novidades**
- **História:** a campanha agora tem início, meio e fim de capítulo. Novo jogo começa no prólogo e segue sozinho de cena em cena.
- **Prólogo, "As estrelas":** Jupiter criança e o avô olham o céu na colina, ao lado do telescópio. Primeira cutscene do GDD.
- **Prólogo, "A montanha" (jogável):** seis anos depois, após o enterro, Jupiter sobe a montanha, fala com o céu e segue a estrela até cair no buraco.
- **Memória, "Sophie":** dois anos antes, no quarto. A lembrança que virou medo.
- **Fase 2, "Ecos":** 6 salas novas com três mecânicas:
  - Rochas frágeis: racham quando você pisa e caem logo depois. Voltam sozinhas.
  - Orbe de voz: dá ao Jupiter a voz que ele nunca usou. Ele brilha enquanto estiver com ela.
  - Barreiras de palavras: só quebram com um dash carregando a voz.
- **Chefe 1, "Sophie":** a sombra da Sophie arremessa palavras (rajadas que miram em você, chuva com uma brecha e frases rasteiras). Pegue a voz e dê dash nela. Três acertos, e cada um deixa a luta mais rápida.
- **Epílogo, "A voz":** fim do Capítulo 1.
- Caixa de diálogo com texto letra por letra e voz própria para cada personagem.
- Trilha sonora original: memória, memória sombria, montanha, caverna e chefe.
- Sons novos: diálogo, rochas rachando, orbe de voz, barreira quebrando, gritos, palavras, acertos e derrota da Sophie, estrela no céu e a queda.
- Menu de pausa (Esc): continuar, voltar ao checkpoint ou ir ao menu.
- O jogo salva o capítulo atual. O menu ganhou "Continuar".
- Personagens novos: o avô, Jupiter criança e Sophie.

**Mudanças**
- Menu: "Novo jogo", "Continuar" e lista de capítulos em duas colunas.
- Botões redesenhados na paleta do jogo, mais finos.
- Troca de cena com fade.
- A Fase 1 ganhou música e agora leva para a memória da Sophie.
- Esc no meio da fase abre a pausa em vez de voltar direto ao menu.

**Técnico**
- Campanha configurável no Inspetor (`autoload/story.tscn`).
- Cutscenes escritas como roteiro (`await say(...)`), com Esc para pular.
- 73 testes automáticos. Robôs jogam a Fase 2, a luta contra a Sophie e todas as cutscenes até o fim.

**Problemas conhecidos**
- Arte ainda provisória.
- A música do menu não vem no repositório. Sem ela, o menu toca o tema da memória.

### v0.3.1 · 04/11/2026

**Correções**
- O som de chegada no feixe de luz soava estourado. Refeito mais suave: menos notas, mais grave, menos eco e volume menor.

### v0.3.0 — Fase 1: A Queda · 04/11/2026

**Novidades**
- **Fase 1, "A Queda":** 7 salas que ensinam as mecânicas aos poucos. Jupiter cai pelo buraco até a caverna e aprende a andar, pular, segurar o pulo, desviar de espinhos, pular na parede, usar o dash e encadear cristais, até chegar à luz.
- Salas de verdade: a câmera desliza entre as salas e você renasce na entrada da sala atual.
- Dicas escritas no próprio cenário, que aparecem quando o Jupiter chega perto.
- Estrela adormecida: novo checkpoint, um cristal num pedestal que acende quando você passa.
- Animações novas do Jupiter: respiração e piscada, corrida em 6 quadros, cabelo ao vento, topo do pulo, queda, parede com a mão apoiada e pouso agachado.
- Poeira ao pular, pousar, pular na parede e correr.

**Mudanças**
- A fonte pixelada voltou.
- Mensagens na tela agora aparecem no topo, sem cobrir o Jupiter.
- A sala de teste virou "Dev: sala de teste" no menu.
- O telescópio saiu do checkpoint. Ele fica guardado para as cutscenes.

**Correções**
- A linha clara de 1 pixel nas bordas da sala sumiu.
- O menu mostrava 4 estrelas em vez de uma.

**Problemas conhecidos**
- Arte ainda provisória.
- A música do menu não vem no repositório (veja o CONTRIBUTING).

### v0.2.0 — Arte e movimento · 04/11/2026

**Novidades**
- Jupiter redesenhado (12×16, com contorno e sombras) e animado: parado, corrida, pulo, queda, parede e dash.
- Rastro do dash com a silhueta da pose do Jupiter.
- Arte nova: rocha com textura e cantos arredondados, espinhos de cristal, estrela-guia cintilante, telescópio de latão, cristais facetados e ícones de vida.
- Fundo com profundidade: camada de estalactites em silhueta além das luzes distantes.

**Mudanças**
- Pulo refeito: segurar mantém a subida firme por um instante e depois cai limpo. Toque curto = pulo baixo (1,6 bloco), segurado = pulo alto (3,8 blocos).
- Pular correndo dá um impulso extra para frente.
- Correção de quinas: pulo e dash deslizam até 3 px para contornar bordas em vez de travar.
- Renderização em alta resolução com pixel art nítida: movimento e câmera mais suaves.
- Hitbox do Jupiter ajustada à altura do novo sprite (6×12).

**Correções**
- O primeiro fantasma do dash aparecia vindo da origem da fase.

**Problemas conhecidos**
- Arte ainda provisória.
- A música do menu não vem no repositório (veja o CONTRIBUTING).
- Linha clara de 1 pixel nas bordas da sala.

### v0.1.0 — Protótipo · 04/11/2026

**Novidades**
- Menu principal com seleção de fases. Build de desenvolvimento: todas as fases liberadas.
- Movimentação: corrida, pulo variável, deslizar e pular na parede, dash em 8 direções.
- Estrela-guia: segue o Jupiter e é a única luz da caverna. O brilho diminui junto com a vida.
- Vida em estrelas: começa com 3 (máx. 5). Espinhos e quedas tiram 1. Sem estrelas, a sala recomeça.
- Itens: estrelas (recuperam vida), cristais (recarregam o dash no ar) e telescópios (checkpoints).
- Sala de teste com 5 trechos: pilares sobre espinhos, poço de pulo na parede, vão de dash, sequência de cristais e saída.
- Efeitos sonoros em clima de sinos e eco: pulo, pouso, dash, morte, estrela, cristal, telescópio, saída e menu.
- Menu com suporte a música.
- HUD com vida e mensagens.
- Suporte a teclado e controle.

**Técnico**
- Salas feitas com TileMapLayer e autotile. Objetos são cenas para arrastar no editor.
- Valores de movimentação ajustáveis no Inspetor.
- Buses de áudio separados para música e efeitos.
- 27 testes automáticos com GUT.

**Problemas conhecidos**
- Arte provisória.
- A música do menu não vem no repositório (veja o CONTRIBUTING).
- Linha clara de 1 pixel nas bordas da sala.
