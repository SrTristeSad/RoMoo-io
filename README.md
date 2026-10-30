# RoMoo io — Moo-IO adaptado ao Roblox 3D

**Revisão atual:** mundo gerado usando como referência o servidor [Moo-IO Lua](https://github.com/SrTristeSad/Moo-IO) e sua implementação em [ToonRoyale-Assets/android/server-lua](https://github.com/SrTristeSad/ToonRoyale-Assets/tree/main/android/server-lua). A referência inclui o mundo, colisões, biomas, corrente do rio e ID original do lobo (4). O núcleo da geração é adaptado para studs e Terrain do Roblox, **não é um port integral de todos os sistemas originais**.

## O que funciona nesta versão

- **Avatar padrão R15** do Roblox, com marreta 3D equipada, WASD, mouse para mirar, botão direito para orbitar a câmera elevada e roda para zoom.
- **Mapa gerado em 7×7 setores:** árvores e arbustos espalhados por todo o campo e neve, excluídos do rio; não encher o deserto de árvores.
- **Biomas nativos do Terrain**: neve ao norte, grama no meio, deserto ao sul.
- **Rio central, reto, sem pontes**, água real do Terrain, espuma deslocando para **+X**, corrente física que empurra o jogador e reduz sua velocidade de natação.
- **Limites físicos invisíveis** em todas as extremidades e salvamento pelo servidor de jogadores que caírem fora do terreno.
- **Árvores, arbustos com frutas, pedras e minérios de ouro não quebram jamais**: cada golpe da marreta concede madeira, comida, pedra ou ouro, sem durabilidade ou respawn.
- **Lobos hostis 3D**, ID 4 do Moo-IO. Perseguem jogadores, compartilham alertas entre membros da matilha, contornam obstáculos por índice espacial, atacam de perto, têm barra de vida, podem morrer e reaparecem.
- **Golpes por direção, como no MooMoo.io**: clique/segure com a marreta; o servidor encontra o alvo no alcance e no cone frontal, sem exigir clicar exatamente na superfície de cada árvore ou lobo. Envie apenas o vetor de mira (controle validado no servidor).
- **Cura com comida:** pressione **Q** ou o botão **CURAR** no celular; gaste 10 alimentos e recupere até 32 de vida. O servidor valida saldo, vida e intervalo de 1,25 s; há uma barra de vida compacta no HUD.
- **Progressão por idade e experiência:** cada golpe de coleta concede XP igual ao recurso recebido; derrotar um lobo rende 80 XP e construir concede 15 XP. Barra de idade no HUD; os requisitos de experiência crescem com a idade.
- **Construções 3D de sobrevivência:** parede de madeira (idade 1), espinhos (idade 2), moinho (idade 3) e **muro de pedra reforçado (idade 4)** com custos, limites por jogador, vida e posicionamento validados pelo servidor. Espinhos ferem lobos e adversários; moinho produz ouro periodicamente. Lobos podem atacar construções.
- **Barra de construção e prévia no terreno:** teclas **1 marreta, 2 parede, 3 espinhos, 4 moinho e 5 muro de pedra**. Os bloqueados mostram a idade necessária. A prévia indica áreas inválidas em vermelho; a validação final é sempre do servidor.
- **Modelos alternativos de árvores/lobos da Creator Store** disponíveis para importar pelo Studio; a geometria procedural padrão mantém o jogo funcionando sem download ou compra de malhas.
- HUD compacta para madeira, pedra, ouro e comida; destaque do alvo e recompensa flutuante por golpe.
- Regras e recompensas verificadas no servidor, não calculadas pelo cliente.

## Abrir e jogar

1. Abra a [compilação mais recente no GitHub Actions](https://github.com/SrTristeSad/RoMoo-io/actions/workflows/build-studio.yml).
2. Baixe o artefato **RoMoo-io-Teste-Roblox-Studio** da execução mais recente aprovada.
3. Extraia `RoMoo-io-Teste.rbxlx` e abra no Roblox Studio.
4. Pressione **F5**. Use WASD para mover, mouse para apontar e clique/segure para golpear **na direção do mouse**, mesmo sem clicar exatamente sobre um objeto. Colete frutas nos arbustos e pressione Q para curar a vida perdida contra lobos.
5. Encontre o rio horizontal, entre na água para sentir a corrente; tente andar além do limite do mapa; enfrente lobos.
6. Colete materiais com a marreta. Os golpes fornecem XP e, ao atingir **100 XP**, você chega à **idade 2**, liberando os espinhos. Na idade **3**, libera o moinho; na **4**, libera o muro de pedra. O servidor impede construir antes do desbloqueio.
7. Use os atalhos **1 = marreta**, **2 = parede (10 madeiras)**, **3 = espinhos (20 madeiras + 5 pedras)**, **4 = moinho (50 madeiras + 10 pedras)**, **5 = muro de pedra (30 pedras + 10 madeiras)**. A prévia fica verde quando a posição parece livre e vermelha quando bloqueada. Construções têm vida e podem ser destruídas; recursos naturais continuam permanentes.

Testes para o **Command Bar do servidor em Play**: `tests/StudioWorldSmokeTest.luau` (mundo), `tests/StudioMeleeHealingSmokeTest.luau` (combate), `tests/StudioBuildingSmokeTest.luau` (construções) e `tests/StudioProgressionSmokeTest.luau` (XP, idade, desbloqueios).

## Modelos 3D disponíveis na Creator Store (importação opcional)

- Árvore low-poly gratuita — https://create.roblox.com/store/asset/3287226226/LowPoly-Tree
- Lobo 3D gratuito — https://create.roblox.com/store/asset/12181904793/Wolf

Esses são assets publicados por **criadores independentes na plataforma Roblox**, não modelos oficiais da Roblox Corporation. O lobo encontrado contém scripts: a importação exclui qualquer `LuaSourceContainer` e mantém somente geometria segura.

No Roblox Studio, **fora de Play**, abra View/Exibir → Command Bar e execute:

```lua
require(game:GetService("ServerScriptService").RoMoo.CreatorAssets).install()
```

Os modelos são armazenados em `ServerStorage/RoMooResourceModels/Tree` e `ServerStorage/RoMooAnimalModels/Wolf`. Salve o place após importar. Se o Studio exigir permissões para assets de terceiros, ative a opção adequada para a experiência ou insira os modelos manualmente na Creator Store e remova os scripts. O build GitHub não incorpora automaticamente meshes de terceiros.

## Organização

- `src/server/World.luau` — gerador de Terrain, água, biomas, recursos e bordas.
- `src/server/MapRules.luau` — regras de bioma e posicionamento.
- `src/server/RiverFlow.luau` — corrente física +X e lentidão.
- `src/server/Boundaries.luau` — proteção física e recuperação nas bordas.
- `src/server/Wolves.luau` — modelos 3D e IA hostil.
- `src/server/CreatorAssets.luau` — importação opcional segura da Creator Store.
- `src/server/Game.server.luau` — processamento de golpes, coleta, cura, lobos e inventário.
- `src/server/Melee.luau` — teste de mira, cone de golpe, distância e oclusão pelo servidor, inclusive paredes.
- `src/server/Structures.luau` — posicionamento 3D, custos, limites, idade mínima, dano, espinhos e moinhos.
- `src/server/Progression.luau` — XP, crescimento da idade, desbloqueios e atributos replicados ao cliente.
- `src/server/Avatar.luau` — avatar e Tool.
- `src/client/Client.client.luau` — mira do mouse, câmera 3D, HUD e efeitos.
- `docs/COMO_TESTAR.md` — checklist de teste.
- `docs/MAPA_MOO_IO.md` — comparação objetiva com gerador Lua original.
- `docs/DEPRECACOES_ROBLOX.md` — APIs antigas e recursos sendo substituídos.

**Outros sistemas ainda não retomados:** clãs, escolhas alternativas de upgrades e outras espécies. O balanceamento das novas armas é provisório para Roblox 3D. Os módulos antigos continuam no histórico e no repositório, mas não foram ligados à build atual. Parede, espinhos e moinho já estão ativos nesta etapa. Os custos são uma adaptação inicial para a escala 3D, não uma cópia 1:1 de todo o catálogo original.

## Compatibilidade e licenças

Este projeto independente referencia código do Moo-IO Lua sob AGPL-3.0-only: ver `LICENSE` e `NOTICE.md`. Não é afiliado ao MooMoo.io oficial. O jogo usa APIs Roblox atuais como `Terrain:FillBlock` e `AssetService:LoadAssetAsync` para importação opcional, não os métodos antigos de voxels ou dependência de Compatibility Lighting.

Compilação automatizada verifica sintaxe Luau, integração dos módulos, presença das regras de coleta infinita e geração de arquivo Roblox XML. **Não substitui teste jogável no Studio.**


## Nova fase — Armas 3D e combate jogador contra jogador

- **Marreta (idade 1)**: coleta natural ilimitada, 12 de dano PvP, 25 contra lobos; ataques a cada 0,42 s.
- **Machado (idade 3, tecla 6)**: arma 3D com lâmina metálica, bônus de 60% nos recursos coletados, 18 de dano PvP e 38 contra lobos; ataques a cada 0,53 s.
- **Espada (idade 5, tecla 7)**: lâmina metálica 3D, 34 de dano PvP e 60 contra lobos; golpes a cada 0,38 s, com penalidade de coleta.
- O avatar padrão R15 continua intacto. Apenas a geometria da `Tool` na mão muda, sem baixar modelos ou substituir corpo e roupas.
- A barra inferior agora é **rolável horizontalmente** com 7 opções: 1–5 ferramentas/construções anteriores, 6 machado, 7 espada. Itens com idade insuficiente permanecem bloqueados.
- **PvP autoritativo**: o cliente envia direção do golpe; o servidor determina alcance, cooldown, alvo e dano. `ForceField` inicial protege contra ataques. Ao derrotar outro jogador, +100 XP, mais 1 abate; o alvo contabiliza morte.
- O HUD mostra **abates e mortes**. A arma escolhida é reaplicada após o personagem reaparecer.
- A coleta de árvores, arbustos, ouro e pedras continua INFINITA, mesmo com machado ou espada; esses recursos não têm HP, não desaparecem e não reaparecem.

**Teste:** no Roblox Studio, inicie **Test > Server & Clients** com 2 jogadores. Entre na idade 3 para selecionar o machado e na 5 para selecionar a espada. Confira danos PvP, proteção de nascimento, respawn, recolhimento e HUD. `tests/StudioWeaponsSmokeTest.luau` verifica geometria, idade e parâmetros básicos na Command Bar do servidor.

Este é um ajuste de balanceamento do protótipo 3D, não a reprodução exata das estatísticas originais do MooMoo.io. Compilação de scripts não comprova que o PvP funciona no Studio.
