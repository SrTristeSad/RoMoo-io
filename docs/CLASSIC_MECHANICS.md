# Referência mecânica — MooMoo.io → RoMoo io

Objetivo: aproximar a experiência do jogo de referência sem copiar código, marca ou assets de terceiros. RoMoo usa modelagem original com Roblox/Luau.

Fontes de referência:
- Site oficial: https://moomoo.io/
- Controles oficiais: https://moomoo.io/?lang=en
- Progressão: https://moomooio.fandom.com/wiki/Age
- Moinhos: https://moomooio.fandom.com/wiki/Windmill

## Correspondência de controles
| Mecânica | MooMoo.io | Implementação RoMoo 0.2 |
| --- | --- | --- |
| Movimento | WASD | Controles nativos Roblox |
| Mira | Mouse | Rotação em plano horizontal com mouse |
| Ataque / coleta | Mouse / espaço | Clique / espaço no item selecionado |
| Ataque automático | E | E alterna uso contínuo |
| Seleção de itens | 1–9 | 1–9 e hotbar visual |
| Comida rápida | Q | Q |
| Travar rotação | X | X |
| Mobile | Joystick + mira | Joystick Roblox, mira por toque direito e USAR |
| Construções | Item + clique | Item + clique, prévia holográfica |

## Fidelidade implementada em código (sem validação no Studio)
- Árvore, pedra, mina de ouro e arbusto; coleta por pancada na direção apontada.
- Recursos acumulados por sessão e XP por coleta.
- Progressão por idade e escolhas de equipamento nas idades 2 e 3.
- Marretas, machados e espadas simplificados com dano/rendimento distintos.
- Parede de madeira, parede de pedra, espinhos e moinho.
- Moinhos geram ouro + XP por segundo, com limite de sete por jogador.
- Construções, colisões, custo, limites e cooldown validados no servidor.
- PvP com dano e abates, reinício de progressão após a morte.

## Pendências de fidelidade (não confundir com concluído)
- Modelos visuais do personagem e armas próximos da silhueta simples .io.
- Escolhas até idade 9, com todas as alternativas do original.
- Comportamento de animais (vacas, touros, lobos), dano, IA, drops.
- Biomas de neve, rio, deserto e minimapa real.
- Arcos, flechas, efeitos de status, escudos, construções avançadas.
- Clãs, chat, menus, loja de chapéus, acessórios e placar.
- Layout e gestos móveis ajustados em aparelhos reais.
- Testes de rede, carga e publicação via Roblox Studio.

Os custos e tempos são provisórios e devem ser equilibrados após teste com dois jogadores.
