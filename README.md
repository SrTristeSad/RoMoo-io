# RoMoo io — Sobrevivência .io em Roblox (Luau)

Jogo multiplayer 3D construído no **Roblox Studio**, recriando o funcionamento central de jogos de sobrevivência e construção no estilo do MooMoo.io. Projeto independente, com código, modelos e identidade próprios; não inclui código ou assets de terceiros.

> **Versão de desenvolvimento 0.2**: mecânicas implementadas em scripts, **ainda não testadas em sessão do Roblox Studio**. Não é uma versão pronta para lançamento.

## O que já existe no código

- **Visão elevada** e mira com o mouse; personagem 3D arredondado com arma e barra de vida.
- **WASD** para movimento; clique/espaço para atacar, coletar ou construir com o item selecionado.
- **E** liga/desliga ataque automático; **Q** consome comida; **X** trava direção da mira.
- **Hotbar com nove posições**, seleção por teclas `1–9` ou toque na interface.
- **Coleta** de madeira, pedra, ouro e comida por golpes; rendimento diferente por ferramenta.
- **XP e idade**, com escolhas de equipamento nas idades 2 e 3.
- **Construções** de parede de madeira, parede de pedra, espinhos e moinho.
- **Moinhos** produzem ouro e XP a cada segundo enquanto estão ativos.
- **PvP**, abates, reinício da progressão após a morte e dano validado no servidor.
- **Fauna** com vacas e ovelhas que fogem e touros e lobos que perseguem e atacam; caça fornece comida e XP.
- **Arquivos 3D CC0 incluídos:** vaca, touro e lobo em glTF; ovelha em FBX. O jogo usa automaticamente as versões importadas do Roblox quando encontradas em `ServerStorage/RoMooAnimalModels`. Veja `docs/IMPORTAR_ANIMAIS_3D.md`.
- **Mapa 3D** gerado automaticamente, com grade discreta, neve no norte, deserto no sul, árvores, pedras e arbustos; **minimapa com jogadores**.
- Controle por **toque**: joystick nativo Roblox, toque direito para mirar, botão USAR e botão COMER.

## Abrindo o projeto no Roblox Studio

Este projeto usa [Rojo](https://rojo.space/) para montar o Place a partir dos scripts.

1. Instale o [Roblox Studio](https://create.roblox.com/) e o plugin Rojo.
2. Instale a CLI Rojo compatível com a versão do plugin.
3. Clone ou baixe o repositório.
4. Na raiz do projeto, execute `rojo serve`.
5. Abra um **Baseplate** novo no Studio, conecte o plugin Rojo e sincronize.
6. Clique em **Play** para testar. Para multiplayer, use **Test → Server & Clients** com dois clientes.

Como alternativa, execute `rojo build -o RoMoo.rbxlx` e abra o Place XML no Studio.

O jogo **não depende de DataStore** nesta etapa. Ouro, recursos e idade são dados temporários da partida.

## Controles de PC

| Tecla | Ação |
| --- | --- |
| WASD | Movimento |
| Mouse | Direção de ataque |
| Clique esquerdo / Espaço | Usar item (golpear ou construir) |
| E | Alternar ataque automático |
| Q | Comida rápida |
| X | Travar/destravar mira |
| 1–9 | Selecionar posições da hotbar |

Ações são enviadas ao servidor e verificadas contra inventário, alcance, cooldown, permissões, idade e limites de construção.

## Estrutura

- `default.project.json` — sincronização do Rojo.
- `src/shared/Config.luau` — regras, itens, custos, idades e balanceamento.
- `src/server/World.luau` — geração do mapa e recursos.
- `src/server/Avatar.luau` — avatares arredondados, ferramentas e barras de vida.
- `src/server/Animals.luau` — animais, comportamento, dano, recompensa e respawn, com suporte aos modelos importados.
- `assets/animals/` — malhas de quatro animais CC0 prontas para importar no Studio.
- `docs/IMPORTAR_ANIMAIS_3D.md` — procedimento de importação e créditos/licença.
- `src/server/Game.server.luau` — economia, combate, progresso, construções e rede.
- `src/client/Client.client.luau` — câmera, controles e HUD.
- `docs/CLASSIC_MECHANICS.md` — equivalência com a experiência de referência.
- `docs/TEST_CHECKLIST.md` — testes obrigatórios no Studio.
- `docs/ROADMAP.md` — itens pendentes até a versão comercial.

## Próximas etapas

Animais e IA, mais armas, upgrades até idade 9, rios e efeitos de bioma, clãs e minimapa; depois desempenho, segurança, testes mobile e cosméticos.

**Importante:** código presente no GitHub não significa que a experiência foi compilada e testada. Antes de publicar ou ativar monetização, conclua a checklist de validação.
