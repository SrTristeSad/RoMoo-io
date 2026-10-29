# RoMoo io — Sobrevivência .io em Roblox (Luau)

Jogo multiplayer 3D construído no **Roblox Studio**, recriando o funcionamento central de jogos de sobrevivência e construção no estilo do MooMoo.io. Projeto independente com arte 3D própria. O port das regras do servidor Lua de Moo-IO usa referência AGPL-3.0, respeitando os avisos de origem e o servidor upstream Apache-2.0. Não é uma cópia dos arquivos proprietários do jogo MooMoo.io.

> **Versão de desenvolvimento 0.7 (câmera 3ª pessoa, coleta e fauna 3D)**: mecânicas implementadas em scripts, **ainda não testadas em sessão do Roblox Studio**. Não é uma versão pronta para lançamento.

## O que já existe no código

- **Câmera de terceira pessoa do Roblox**, zoom com roda do mouse, rotação com botão direito e mira por raycast do cursor; personagem 3D com arma e barra de vida.
- **WASD** para movimento; clique/espaço para atacar, coletar ou construir com o item selecionado.
- **E** liga/desliga ataque automático; **Q** consome comida; **X** trava direção da mira.
- **Hotbar dinâmica com até 13 itens desbloqueados visíveis** em até três linhas, sem esconder itens obtidos em um menu. Atalhos 1–9, 0, - e =, R; seleção também por toque/clique.
- **Coleta por golpes de árvore, pedra, ouro e arbusto**: recursos concedidos por acerto, medidor de durabilidade, destruição visual ao esgotar vida e respawn. Ângulo de coleta portado do servidor Lua Moo-IO (~69°).
- **XP e idade**, com escolhas de equipamentos nas idades 2 a 9, validadas pelo servidor. Armas novas com danos, alcance e capacidade de coleta próprios.
- **Construções**: madeira, pedra, muralha reforçada, espinhos de madeira/pedra, armadilha de chão, plataforma curativa e três níveis de moinhos.
- **Moinhos** produzem ouro e XP a cada segundo enquanto estão ativos.
- **PvP**, abates, reinício da progressão após a morte e dano validado no servidor.
- **Clãs temporários por código numérico** criado pelo servidor (até 8 membros); painel recolhível de criar/entrar/sair, tag no nome e cores de aliados no minimapa.
- **Jogabilidade de equipe:** sem dano entre aliados, espinhos e construções dos companheiros protegidos, plataformas curativas ajudam aliados próximos.
- **Cobertura real para golpes:** muralhas bloqueiam golpes que tentariam atravessar uma parede; armadilha de lentidão restaura corretamente a velocidade após reaplicações.
- **Feedback visual local** de ataque, coleta, impacto, cura e construção (efeitos não replicados como peças).
- **Comida com cooldown próprio**, para poder curar durante o combate sem bloquear golpes.
- **Fauna 3D autoral com oito espécies**: vaca, porco, ovelha, touro, Bully, lobo, javali e yeti, com perseguição/fuga e recompensas. Usa automaticamente modelos low-poly gerados em Luau quando não existem MeshParts importados.
- **Caminhada procedural** para os quatro tipos de animal, com oscilação leve e fuga mais longa após receber dano; surgimento evita recursos e outros animais.
- **Itens visíveis na mão:** maçã, biscoito e prévia de construção quando selecionados na hotbar.
- **Arquivos 3D CC0 incluídos:** vaca, touro e lobo em glTF; ovelha em FBX. O jogo usa automaticamente as versões importadas do Roblox quando encontradas em `ServerStorage/RoMooAnimalModels`. Veja `docs/IMPORTAR_ANIMAIS_3D.md`.
- **Mapa 3D autoral**, com grama 3D, flores, pedrinhas, pinheiros de neve e cactos no deserto; árvores com copas em camadas e minimapa com os três biomas. A grade antiga fica desativada por padrão.
- **Decoração limitada e sem colisão**, para não bloquear movimento, coleta, combate e construção. Quantidades ajustáveis em `Config.Decoration`.
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
| 1–9, 0, -, =, R | Selecionar até 13 itens da hotbar, na ordem exibida |

Ações são enviadas ao servidor e verificadas contra inventário, alcance, cooldown, permissões, idade e limites de construção.

## Estrutura

- `default.project.json` — sincronização do Rojo.
- `src/shared/Config.luau` — regras, itens, custos, idades e balanceamento.
- `src/server/World.luau` — geração do mapa e recursos.
- `src/server/WorldDecor.luau` — decoração procedural 3D leve e determinística.
- `docs/ART_DIRECTION.md` — referências de direção visual e limites de desempenho.
- `tests/StudioWorldSmokeTest.luau` — verificação manual via Command Bar do Studio.
- `src/server/Avatar.luau` — avatares arredondados, ferramentas e barras de vida.
- `src/server/Animals.luau` — animais, comportamento, dano, recompensa e respawn, com suporte aos modelos importados.
- `src/server/AnimalModels.luau` — animais 3D procedurais usados automaticamente quando não há mesh importada.
- `docs/MOO_LUA_PORT.md` — mapeamento do servidor Lua original, licenças e módulos ainda pendentes.
- `assets/animals/` — malhas de quatro animais CC0 prontas para importar no Studio.
- `docs/IMPORTAR_ANIMAIS_3D.md` — procedimento de importação e créditos/licença.
- `src/server/Game.server.luau` — economia, combate, progresso, construções e rede.
- `src/server/Clans.luau` — clãs da partida, códigos únicos e segurança de aliados.
- `docs/CLANS_AND_COMBAT.md` — regras, limites e roteiro de teste multiplayer.
- `src/client/Client.client.luau` — câmera, controles e HUD.
- `src/client/Effects.luau` — efeitos de dano, coleta, cura e construções no cliente.
- `docs/CLASSIC_MECHANICS.md` — equivalência com a experiência de referência.
- `docs/TEST_CHECKLIST.md` — testes obrigatórios no Studio.
- `docs/ROADMAP.md` — itens pendentes até a versão comercial.

## Próximas etapas

Testar os clãs com dois jogadores e o combate com muralhas; revisar armadilhas, animais e HUD móvel. Depois: rios e caminhos entre biomas, otimizações e cosméticos.

**Importante:** código presente no GitHub não significa que a experiência foi compilada e testada. Antes de publicar ou ativar monetização, conclua a checklist de validação.
