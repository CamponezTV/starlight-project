# Starlight

Plataforma 2D em pixel art sobre Jupiter, seu avô e as estrelas. Feito em Godot 4.7.

**Como jogar:** abra o `project.godot` no [Godot 4.7](https://godotengine.org) (versão padrão) e aperte **F5**.

| Ação | Teclado | Controle |
|---|---|---|
| Mover | Setas / WASD | Analógico / D-pad |
| Pular | Espaço / C / J | A |
| Dash | X / K / Shift | X / B |
| Voltar ao checkpoint | R | Back |
| Voltar ao menu / Sair | Esc | — |

Documentação para desenvolvimento: [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Patch Notes

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
