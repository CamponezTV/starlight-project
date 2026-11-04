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
