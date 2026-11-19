# Starlight

Plataforma 2D em pixel art sobre Jupiter, seu avô e as estrelas. Feito em Godot 4.7.

**Como jogar:** abra o `project.godot` no [Godot 4.7](https://godotengine.org) (versão padrão) e aperte **F5**.

**Idiomas:** português (original) e inglês. Troque em Configurações, no menu ou na pausa.

| Ação | Teclado | Controle |
|---|---|---|
| Mover | Setas / WASD | Analógico / D-pad |
| Pular | Espaço / C / J | A |
| Dash | X / K / Shift | X / B |
| Avançar diálogo | Espaço / Enter | A |
| Conversar / Escolher resposta | Cima / Cima e Baixo | Analógico / D-pad |
| Voltar ao checkpoint | R | Back |
| Trocar valor nas configurações | Esquerda e Direita | Analógico / D-pad |
| Pausa / Pular cutscene | Esc | — |

Documentação para desenvolvimento: [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Patch Notes

### v0.15.2 — A Sophie cresce com a música · 18/11/2026

**Novidades**
- **Tamanho da janela:** a opção "Tela cheia" virou "Tela": escolha a janela de 640x360 até a maior que cabe no seu monitor, ou a tela cheia. O jogo continua desenhado em 320x180 e escalado em números inteiros, para o pixel art não borrar.

**Mudanças**
- **A trilha da Sophie acompanha a luta:** agora são quatro trilhas, uma para cada ponto de vida que ela perde, cada uma mais rápida (de 80 a 116 batidas por minuto) e mais pesada que a anterior.
  - **Fase 1:** quase só pavor: o coração, o bordão grave e a caixinha de música da infância tocando o tema desafinada. Os tambores entram só no fim.
  - **Fase 2:** a marcha: cordas insistindo, tambores de guerra e o tema nos metais graves.
  - **Fase 3:** o tema também uma oitava acima, com coro, tambores em todo tempo e um "BRAAM" a cada frase.
  - **Fase 4:** tudo junto e sem respiro: cordas correndo, tambores dobrados, um coro tremendo lá em cima e guinchos.
- **A troca é suave:** no golpe, a trilha nova cresce aos poucos enquanto ela está atordoada, e a antiga some. Se o Jupiter cai, a luta e a música voltam para o começo do mesmo jeito.
- **Toda troca de música ficou mais suave:** o crossfade não afunda mais o volume no meio.

**Técnico**
- `SophieBoss.phase_music`: uma trilha por fase.
- Builds para Windows, Linux e Mac (`export_presets.cfg`). A música de terceiros, os testes e as ferramentas ficam de fora do jogo exportado.
- Testes novos: a trilha troca aos poucos a cada golpe e volta no reset, cada trilha é mais rápida que a anterior, toda trilha de `music/` faz loop, o crossfade mantém o volume e a linha "Tela" passa pelos tamanhos e pela tela cheia. 173 testes automáticos.

### v0.15.1 — Uma morte de cada vez e a Sophie com trilha · 18/11/2026

**Correções**
- **Morte dupla:** às vezes o Jupiter renascia e morria de novo na hora, como se tivesse nascido em cima da Sophie. Era o toque de antes: a Sophie e os sussurros ainda achavam, por um quadro, que ele estava onde tinha morrido. Agora cada toque mata uma vez só.

**Mudanças**
- **Trilha da luta com a Sophie refeita:** a antiga era quase toda baixa e sumia por baixo dos golpes. A nova é "A Promessa", o tema do jogo, em Ré menor: começa no pavor (um bordão grave, o coração e a caixinha de música da infância tocando o tema desafinada), vira uma marcha (cordas, tambores de guerra, coro e o tema lento nos metais graves) e explode no clímax (o tema em oitavas, tambores dobrados, um "BRAAM" a cada frase e guinchos agudos). Termina num acorde de trítono e no silêncio, só com o coração, antes de recomeçar.

**Técnico**
- Testes novos: encostar na Sophie e num sussurro conta uma morte só. 167 testes automáticos.

### v0.15.0 — A voz e os Ecos mais difíceis · 18/11/2026

**Novidades**
- **A voz no holofote:** a primeira orbe de voz da Fase 2 para o jogo e apresenta a habilidade, como o dash: "VOZ — Com a voz, X quebra barreiras".
- **Pegar a voz tem animação:** a orbe é sugada num estouro de faíscas com um clarão de luz, a aura do Jupiter acende grande e encolhe, e o corpo dá um tranco. Quando a orbe volta, ela cresce do nada.

**Mudanças: Fase 2 (Ecos) mais difícil**
- **Eco:** a ponte de rochas frágeis tem um buraco no meio: é preciso pular sobre rocha que está caindo.
- **Desmorona:** as rochas da escada caem mais rápido. Não dá para parar nos degraus.
- **Barreiras:** a orbe flutua sobre o poço e só é pega no pulo; o dash na barreira é no ar, a ponte de chegada é mais curta e ainda há um buraco antes do chão.
- **Pontes:** cada ponte tem 2 rochas (eram 3). O pulo inteiro passa direto: é preciso controlar no ar.
- **O Coro:** agora são três sussurros subindo e descendo em onda, no caminho de cada pulo. Só passa quem sai na hora certa e corre sem parar, e ainda precisa guardar a voz para a barreira do fim.
- **O Silêncio:** um cristal só (eram 2): broto, dash até a plataforma, dash, cristal, dash.
- A placa "Pegue e dê dash na barreira" saiu: o holofote explica.

**Técnico**
- `Whisper.phase`: em que ponto do vai-e-volta o sussurro começa.
- Os robôs dizem onde pararam quando falham e confirmam o holofote sozinhos. Robôs novos para O Coro (mede a janela de largada: cerca de 1 em cada 4) e O Silêncio, que não tinham teste. 165 testes automáticos.

### v0.14.3 — Estrelas por visita · 18/11/2026

**Correções**
- **Estrelas perdidas:** sair da fase e entrar de novo mantinha o contador de antes, com as estrelas já pegas apagadas. Agora cada visita começa do zero, com todas as estrelas no lugar para pegar de novo.
- **Estrela da Diana:** quem a perdoou começa toda visita à Fase 3 com a estrela dela contada (a conversa não se repete). Quem não perdoou não vê mais uma estrela impossível na conta: ela sai do total.
- **Música:** parar a trilha no meio de uma troca de faixa deixava a faixa antiga terminando de sumir por baixo. Agora as duas param.

**Técnico**
- Sai o autoload `Stars`, que só servia para gravar as estrelas. A fase conta as estrelas da visita.
- 161 testes automáticos. Novos: a próxima visita começa sem estrelas, a conta da Diana nas duas decisões e parar a música no meio de uma troca.

### v0.14.2 — Chuva, menos cristais e arte corrigida · 18/11/2026

**Mudanças**
- **Chuva do enterro refeita:** era quase só chiado agudo, contínuo e alto por baixo das falas. Agora é chuva de verdade: um lençol de água que sobe e desce com as rajadas, pingos miúdos, algumas gotas grossas por perto e um ronco distante. Começa baixinha na tela preta, sobe com a imagem, abaixa nos planos fechados (com a conversa) e some quando a chuva para.
- **Dash refeito:** um sopro macio com corpo e o brilho de estrela, sem o chiado. Mais baixo, porque toca o tempo todo.
- **Morte e a pancada da mão da Sophie** mais baixas: tocam muitas vezes seguidas.
- **Fase 1 mais difícil, com menos cristais de dash:** a sala dos cristais tem 2 (eram 4), a Travessia não tem nenhum (só a plataforma) e o Salto tem 1 (eram 3). A estrela do Salto agora fica no alto, acima do broto: o impulso dele e um dash para cima.
- **Hospital:** o Jupiter visitava o avô de terno, a roupa do enterro. Agora está de moletom verde com capuz e jeans, no busto e no plano aberto.

**Correções**
- **Camisas dos bustos:** a pele do pescoço aparecia por cima da roupa, como um furo. Agora o pescoço termina na gola, com o decote em curva nas golas redondas.
- **Hospital:** o Jupiter, de costas, parecia sentado virado para o encosto da cadeira. O encosto agora fica na frente das costas dele, com as ripas descendo até a borda do assento.
- **Enterro:** o caminho de pedras passava por cima da cova, do monte de terra e da pá, e havia túmulos em cima dele. Agora desce pela direita, livre.

**Técnico**
- 163 testes automáticos. Dois robôs novos atravessam a Travessia só com a plataforma e pegam a estrela dela; os do Salto e dos cristais foram refeitos para as posições novas.

### v0.14.1 — Tema do menu, ícone, banner e o cabelo do Jupiter · 17/11/2026

**Novidades**
- **Ícone novo do jogo:** a estrela-guia sozinha, grande e dourada, com volume nas pontas, halo e faíscas, no céu noturno.
- **Banner de apresentação** (`promo/banner.png`, 920×430): o logo, a estrela sobre a colina e o Jupiter, pequeno, olhando para ela.

**Mudanças**
- **Discord:** o status mostra só o ícone do jogo (a estrela), em todos os capítulos.
- **Música do menu nova: "A Promessa" à noite.** Só a melodia do tema do jogo, na caixinha de música e nos sinos, com estrelinhas soltas: começa quase em silêncio, a melodia responde aos poucos, toca inteira e volta ao silêncio. Original, como o resto da trilha.
- O menu não usa mais arquivo de música local. O tema em lo-fi continua nos créditos.

**Correções**
- **O cabelo do Jupiter** (criança, adolescente e de pijama) formava um redemoinho em espiral no alto da cabeça. Agora são mechas: a franja por cima, as pontas do topo com luz no meio e sombra entre elas.

**Técnico**
- 161 testes automáticos. Os novos conferem que o menu toca o tema novo e que o ícone do Discord está pronto para enviar.

### v0.14.0 — Pré-alpha: tela de título e configurações · 17/11/2026

**Novidades**
- **Tela de título nova:** a colina do prólogo, com o Jupiter criança e o avô no telescópio, passando devagar ao fundo; nuvens, vaga-lumes, estrelas piscando e estrelas cadentes de vez em quando. Logo novo em pixel art e a frase "uma história sobre não ter pressa".
- **Menu de pré-alpha:** Continuar, Novo jogo, Configurações e Sair. Uma estrela acompanha a opção escolhida, o mouse também funciona e Esc volta (na página principal, só aponta para "Sair").
- **Novo jogo pergunta antes** de apagar um progresso salvo.
- **Configurações** no menu e na pausa:
  - **Idioma:** português ou inglês. Muda na hora, inclusive no meio de uma fase.
  - **Volume:** geral, música e efeitos, em 10 passos (zero emudece).
  - **Texto automático:** as falas passam sozinhas depois de um tempo de leitura (cresce com o tamanho da fala). Apertar continua adiantando.
  - **Tela cheia.**
  - Tudo fica salvo, separado do progresso: um jogo novo não mexe nas configurações.
- **Inglês completo:** todas as falas, legendas, escolhas, dicas, lembranças, falas e palavras da Sophie, o HUD e os menus (378 textos).
- **Status no Discord:** com o Discord aberto no computador, o perfil mostra "Jogando Starlight", o capítulo atual (fase ou lembrança), há quanto tempo e uma imagem daquele capítulo, no idioma escolhido. Funciona em qualquer jeito de entrar numa fase (campanha, capítulos dev ou direto pelo editor). Usa o addon Discord Rich Presence (MIT), em `addons/discord_rich_presence/`.
- **Tema do menu novo:** "A Promessa" em lo-fi, lenta, com piano elétrico, caixinha de música, bateria abafada e chiado de vinil.

**Mudanças**
- **O menu não toca mais música de terceiros.** A faixa local em `menu/music/` deixou de ser usada; o pré-alpha só leva música original.
- Versão no canto: "pré-alpha".
- **Capítulos só para desenvolvimento:** a lista de capítulos (com a sala de teste e os dois finais) saiu do menu. Ela aparece com o código cima, cima, baixo, baixo, esquerda, direita, esquerda, direita, B, A, e fica liberada até o jogo fechar.
- **Nova ordem:** a fase "Fios" vem antes da chefe Sophie. Um save feito depois de "Ecos" pode continuar um passo deslocado.
- **Fim do pré-alpha:** depois da memória da aranha, no lugar de "Capítulo 2: em breve", vêm os créditos: "Fim do pré-alpha", "Obrigado por jogar" e "Criado por Arthur Camponez", sobre o céu da colina.
- A pausa usa o mesmo estilo de opções do menu.

**Técnico**
- 160 testes automáticos. Os novos cobrem as configurações (idioma, volume, salvar e carregar, texto automático), o catálogo de traduções (todo texto tem inglês, nenhum sobra), o inglês cabendo nas caixas (falas, lembranças, palavras da Sophie, todas as páginas do menu), o fluxo do menu e da pausa, o código secreto, a ordem da campanha e o status do Discord.
- Um teste antigo que às vezes falhava por sorte (a piscada dos bustos) agora olha todo quadro.

### v0.13.0 — A Sophie de verdade · 17/11/2026

> Esta versão trata de violência contra criança. Nada é mostrado: a tela escurece e só se ouve.

**História**
- **A Sophie mudou.** Ela deixou de ser a madrasta cansada: é narcisista, vive do dinheiro que o pai do Jupiter manda de longe, bate nele ("vou ter que te corrigir") e o proíbe de contar ("não conta isso pro seu pai, senão vai ver").
- **Memória "Sophie" reescrita:** ela entra sorrindo, humilha (bastardo, "você nem era pra ter nascido") e a agressão acontece com a tela preta. Na noite seguinte o avô vê a marca, o Jupiter conta uma única vez, e o avô, que acha todo mundo bom, diz que ele deve estar confuso. Ele nunca mais tenta.
- **"A voz" (depois da chefe) reescrita** em volta do arrependimento: ele só teve coragem de falar ali embaixo, para uma sombra, e nunca pediu ajuda a ninguém.
- **Enterro, galpão e o final da manhã** acompanham: no enterro ela faz o papel da madrasta dedicada e avisa que ele não tem mais a quem recorrer; no galpão, tranca para "corrigir" e depois diz ao avô que a porta emperrou; no final, chora para os vizinhos.

**Chefe**
- **Sophie redesenhada para dar medo:** uma sombra alta e curvada, de cabelo solto, braços compridos demais, um cinto na mão e um sorriso largo de dentes. Gritando, a mandíbula despenca.
- **Entrada:** primeiro só os olhos e o sorriso no escuro; depois o corpo sai da sombra.
- **O que ela arremessa é o que ela dizia:** LIXO, BASTARDO, CALA A BOCA, "NÃO CONTA PRO SEU PAI", "VOU TER QUE TE CORRIGIR". Quando o Jupiter cai, ela fala por cima ("Engole o choro.", "Levanta.").
- **As respostas do Jupiter** a cada golpe acertado viraram o enfrentamento: "Eu não sou lixo!", "Você me batia!", "Eu devia ter contado pra alguém!", "Eu não tenho mais medo de você!".
- **Clima:** arena bem mais escura, o escuro fechando em volta da tela no ritmo de um coração (mais rápido a cada fase) e um clarão vermelho a cada golpe, da mão dela no chão ou do Jupiter caindo.
- **Trilha nova:** lenta e pesada, com pancadas secas fora do tempo, um coração por baixo e uma caixinha de música quebrada. A mão ganhou um som de pancada próprio.

**Mudanças**
- Duas expressões novas da Sophie nas cutscenes: o sorriso de olhos mortos e a fúria.
- As falas da chefe ficam legíveis no escuro (camada própria, fora da escuridão da fase).

**Técnico**
- 129 testes automáticos. Os novos cobrem a entrada pelos olhos, o clarão e a fala quando o Jupiter cai, o tamanho das palavras arremessadas (para os ataques continuarem desviáveis) e uma resposta para cada golpe.

### v0.12.0 — Estrelas perdidas, o broche e o portal · 17/11/2026

**Novidades**
- **Estrelas perdidas:** as estrelas deixaram de ser vida e viraram o desafio opcional de cada sala. Tocada, a estrela segue o Jupiter, mas só fica guardada quando ele pisa em chão firme. Se ele morrer antes, ela volta para o lugar.
- **Contador de estrelas** no canto da tela ("2/6"). As guardadas ficam salvas com o progresso, aparecem apagadas na visita seguinte e deixam a luz da estrela-guia mais forte.
- **Holofote de habilidade:** ao pegar o broche, o jogo para, a tela escurece em volta do Jupiter, raios de luz giram e o nome da habilidade aparece com a explicação e o botão.
- **Santuário do broche:** sala nova na Fase 1. O broche fica num altar e a saída é uma borda alta que só o dash para cima alcança.
- **Portal de fim de fase:** um arco de pedra com um véu de luz no lugar do feixe. Ele puxa o Jupiter para dentro, a luz toma a tela, vira céu estrelado e mostra o resumo: estrelas guardadas, quedas e tempo.
- **Fase 1 maior:** 12 salas (eram 9). Além do Santuário, entram "O Salto" (três cristais sobre um mar de espinhos e um broto até a porta) e o salão do portal. São 6 estrelas perdidas na fase.

**Mudanças**
- **Sem vidas.** Morrer só leva de volta ao último ponto, quantas vezes for preciso, e a sala recomeça (rochas, orbes, barreiras e o chefe voltam ao início). Antes, três mortes reiniciavam a fase inteira.
- **Estrela redesenhada:** agora tem cinco pontas, diferente da estrela-guia.
- **Broche redesenhado:** uma estrela de quatro pontas com alfinete, no lugar da estrela azul.
- **Dicas da Fase 1** reescritas e afastadas: só uma aparece por vez, acima da cabeça do Jupiter.
- **A dica de controles** só mostra o dash depois que ele é aprendido.
- **Fundo da caverna** sem bordas verde-água: essa cor ficou só para o chão em que se pisa.

**Correções**
- Enfeites espelhados (tufos, cogumelos, cristais) eram desenhados um bloco para o lado: apareciam flutuando fora das bordas ou dentro das paredes.
- Brotos de parede nasciam na quina das bordas e pareciam grama flutuando.
- Dicas vizinhas apareciam ao mesmo tempo, uma por cima da outra.
- Enfeites do chão nasciam embaixo de objetos largos (altar, portal, cabana da Diana).

**Técnico**
- 125 testes automáticos. Os novos cobrem as estrelas perdidas, a morte sem vidas, o holofote, o portal e o resumo, e robôs jogam as salas novas e pegam duas das estrelas.

### v0.11.0 — A subida da montanha · 16/11/2026

**Novidades**
- **A montanha ficou mais de três vezes maior e sobe de verdade.** A trilha tem 378 blocos de comprimento (antes 110) e 38 de subida (antes 8).
- **Patamares largos, degraus variados:** cada trecho tem um assunto (o quintal da casa, o bosque, a clareira do tronco caído, o mirante do banco, a ponte sobre a fenda, a pedra riscada, as árvores secas, o topo), com degraus de 1 ou 2 blocos entre eles. São 23 degraus na subida inteira.
- **Lembranças na trilha:** em sete pontos, um pensamento sobre o avô aparece na tela enquanto o Jupiter anda (o banco, a ponte, o "J + V" riscado na pedra, o banquinho dele esquecido no topo).
- **Cenário:** 60 objetos de 38 tipos, em grupos com espaço vazio entre eles: casa com a janela acesa, lenha, lampiões, portal, pinheiros de cinco formatos, arbustos, samambaia, cogumelos, toco, tronco caído, banco, bandeirinhas, árvores secas, totens, pedras com neve e a árvore torta do topo. O Jupiter passa entre os dois corrimãos da ponte de corda.
- **Profundidade:** a vila acesa fica cada vez mais para baixo, uma serra de mata passa ao fundo, névoa corre nas pedras e vento cruza a tela.
- **Clima de cena:** abre com "Uma hora depois do enterro" e mantém a moldura das cutscenes durante a subida.

**Mudanças**
- **Jupiter sem habilidades na montanha:** só anda e pula. O dash e o pulo na parede ficam travados ali.

**Técnico**
- 111 testes automáticos. Os novos cobrem as habilidades travadas, as lembranças, a altura da subida, a ponte nivelada com as margens e todos os objetos da trilha apoiados no chão.

### v0.10.1 — Planos abertos redesenhados · 15/11/2026

**Mudanças**
- **Todos os planos abertos das cutscenes foram redesenhados** com mais objetos, textura e luz: colina, hospital, enterro, montanha, quarto, galpão, caverna, fundo do buraco, manhã e a cabana da Diana. Os fundos dos planos fechados acompanham.
- **Figuras refeitas:** proporção, sombra no chão, dobras de roupa, cabelo com volume e luz de contorno da cena (lua, lampião, monitor).
- **Cenários com mais vida:** paredes de pedra facetada, tábuas com veios e nós, grama em camadas com flores, pinheiros e casinhas acesas ao longe, capela e cerca no cemitério, serra nevada na montanha.
- **Cabana da Diana na fase** maior e detalhada: telhado de zinco, luzinhas, cortina, janela acesa, lenha e vaso.

### v0.10.0 — Diana e as escolhas · 15/11/2026

**Novidades**
- **Diana:** uma conversa opcional na Fase 3. No chão da sala "Subida" há uma cabana, e nela a Diana (17), amiga que sumiu da vida do Jupiter há dois anos, fuma escondida. Chegue perto e aperte Cima.
- **Escolhas:** mecânica nova. Em alguns momentos da conversa o jogador responde pelo Jupiter (Cima e Baixo trocam a resposta, Espaço confirma). Duas respostas mudam o tom da conversa; a última decide se ele perdoa ou não.
- **A decisão fica:** perdoada, a Diana continua na cabana e entrega o isqueiro (uma estrela). Sem perdão, a cabana fica vazia e a lanterna apagada. A escolha é salva com o progresso; um jogo novo apaga.
- Busto da Diana com 8 expressões, dois planos novos (a cabana na caverna e a parede de tábuas) e uma faixa nova na trilha.

**Mudanças**
- Pular a conversa (Esc) não decide nada: ela continua disponível.

**Técnico**
- 105 testes automáticos. Os novos cobrem a caixa de escolhas, os dois desfechos, a conversa pulada e a cabana na fase.

### v0.9.1 — Fundos de volta e Fase 1 maior · 15/11/2026

**Novidades**
- **Fase 1 maior:** duas salas novas depois da luz. "Brotos" (dois degraus altos demais para o pulo, vencidos com as molas) e "Travessia" (plataforma móvel e um cristal sobre espinhos). A saída foi para o fim da travessia.

**Correções**
- As fases 2 e 3 e a arena da Sophie estavam sem fundo. Voltaram a ter o fundo da caverna.

**Técnico**
- 95 testes automáticos. Um deles garante que nenhuma fase da campanha fica sem fundo.

### v0.9.0 — Dash como habilidade, fases maiores e sons novos · 13/11/2026

**Novidades**
- **O dash agora se ganha.** A Fase 1 começa sem ele; o broche do avô, na sala do vão, ensina. As fases seguintes já começam com o dash.
- **Fase 2 maior:** duas salas novas. "O Coro" (rochas frágeis soltas, um Sussurro no caminho, a voz e uma barreira no fim) e "O Silêncio" (mola, plataforma móvel e dois cristais sobre um mar de espinhos).
- **Fase 3 maior:** duas salas novas. "A Teia" (três plataformas que sobem e descem sobre espinhos) e "O Nó" (duas molas, um Sussurro no ar, a voz e a última barreira).
- **Movimento mais fluido:** o Jupiter inclina o corpo na corrida e no ar e estica ao subir e cair rápido. Os Sussurros flutuam.
- **Efeitos sonoros refeitos** com os instrumentos da trilha (harpa, caixinha de música, piano, cordas e coro): pulo, pouso, dash, morte, estrela, cristal, estrela adormecida, saída, luz apagada e menu. Som próprio para o broto-mola.

**Correções**
- Enfeites do terreno (grama, cogumelos, cristais) nasciam em cima de objetos e uns sobre os outros. Agora nada nasce onde há um objeto, uma dica ou uma plataforma, e nunca dois na mesma célula.

**Técnico**
- 92 testes automáticos. Robôs vencem as duas salas finais novas; o dash travado e os enfeites têm testes próprios.

### v0.8.0 — Chefe novo, Fase 3 e mecânicas · 11/11/2026

**Novidades**
- **Sophie redesenhada:** uma sombra alta com garras, vestido esfarrapado costurado de palavras e boca que abre no grito. Flutua animada, treme quando atordoada e solta estilhaços ao ser atingida.
- **Ataques novos da Sophie:**
  - A mão: mira em você, avisa com um "!" e despenca. O impacto treme a tela e solta duas ondas de choque pelo chão.
  - O anel: palavras em todas as direções, com uma brecha.
  - Na última fase: mão duas vezes seguidas, dois anéis desencontrados e duas frases rasteiras que se cruzam.
- **Luta mais difícil:** 4 pontos de vida (eram 3) e quatro fases, cada uma mais rápida. Arena nova, sem a plataforma do meio.
- **Barra de vida do chefe** na tela.
- **Fase 3, "Fios":** 5 salas com as mecânicas novas.
- **Broto-mola:** lança o Jupiter mais alto que um pulo e devolve o dash.
- **Plataformas móveis:** vão e voltam, na horizontal ou na vertical.
- **Sussurros:** sombras que patrulham. Encostar apaga uma estrela; um dash com a voz desfaz.
- As palavras da Sophie "estouram" na tela ao nascer.

**Mudanças**
- A câmera treme nos impactos da luta.
- A campanha agora termina na Fase 3.

**Técnico**
- 88 testes automáticos, com as mecânicas novas e os ataques da mão e do anel.

### v0.7.0 — Trilha nova e cutscenes com luz · 11/11/2026

**Novidades**
- **Trilha sonora nova, 10 faixas.** Todas giram em torno de um mesmo tema, "A Promessa", que volta transformado em cada cena: caixinha de música na colina, quase parando sobre o bipe do monitor no hospital, em Ré menor no enterro, em oitavas de piano na luta contra a Sophie, com coro no reencontro e num piano só na manhã final.
- Instrumentos novos: piano, naipe de cordas, coro, violoncelo, harpa, caixinha de música e tímpanos. O canal de música ganhou reverb e abertura estéreo.
- **Bustos refeitos:** maiores, com olhos em camadas (íris, pupila, brilho), cabelo com mechas e faixa de luz, sombra arroxeada no rosto e dobras na roupa.
- **Luz de cena nos personagens:** cada ambiente banha os bustos na sua cor e acende uma luz de contorno (azul da lua, verde do monitor, dourado da estrela, laranja da porta).
- **Profundidade nos planos abertos:** grama e galhos em primeiro plano e nuvens ao fundo deslizam em velocidades diferentes.
- Céus mais ricos: nuvens com borda iluminada, lua, pontilhado entre as faixas de cor. Estrelas piscando e vinheta em todas as cenas.
- **Cena nova, "Hospital":** o avô já não reconhece o Jupiter e fala do neto de oito anos para o próprio neto. Por um instante ele volta e cobra a promessa.
- Caixa de diálogo redesenhada.

**Mudanças**
- O enterro agora acontece "três semanas depois" do hospital, e o Jupiter cita o quarto 214.
- No reencontro, o Jupiter percebe que o avô não lembra, como no hospital.
- Menu em quatro colunas, com nomes curtos.
- Saíram as 6 faixas antigas.

### v0.6.0 — Cutscenes de cinema · 10/11/2026

**Novidades**
- **Cutscenes refeitas em planos de cinema.** Cada cena agora corta entre três tipos de plano:
  - plano aberto: figuras pequenas, de costas, diante de um céu enorme;
  - plano fechado: bustos grandes dos personagens, com expressões (triste, vazio, chorando, com medo, com raiva...);
  - detalhe: a mão de uma criança erguida para pegar uma estrela.
- Céus novos em faixas de cor chapada, com nuvens marmorizadas. Moldura arredondada em todas as cutscenes.
- **Roteiro reescrito, mais pesado.** As falas ficaram mais curtas e dizem mais. Um narrador entre parênteses diz o que o Jupiter não quer pensar.
  - O avô explica que a luz das estrelas é a carta de coisas que já morreram, e pede uma promessa: não ter pressa.
  - No enterro, o pai não veio, e Jupiter confessa que não chorou.
  - A Sophie deixou de ser só vilã: está exausta, criando o filho de outra.
  - A memória da aranha agora mostra quando ele aprendeu a ficar calado.
  - Os dois finais (menu dev) foram reescritos.

**Mudanças**
- Caixa de diálogo mais baixa (duas linhas), sempre no alto durante as cutscenes.
- Saíram os personagens articulados e os cenários da v0.5.0.

**Técnico**
- Passos novos de roteiro: `cut_to` (corta de plano) e `pan` (desliza o plano aberto).
- 80 testes automáticos. Um deles confere que toda fala dos roteiros cabe na caixa de diálogo.

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
