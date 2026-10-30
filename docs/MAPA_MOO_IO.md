# Mapa Moo-IO Lua → RoMoo Roblox 3D

Fonte do usuário: `SrTristeSad/ToonRoyale-Assets/android/server-lua/world/objects.lua`, `movement.lua`, `environment.lua`, `animals.lua`, `animal_types.lua` e `wolf_pack.lua`; AGPL-3.0-only, consultar `LICENSE` e `NOTICE.md`.

| Regra Moo-IO Lua | Porta Roblox |
| --- | --- |
| `mapScale=14400` | `MapSize=520` studs (escala reduzida) |
| `areaCount=7` | 7×7 setores determinísticos |
| `treesPerArea=9` | 7 árvores por setor elegível, adaptado para performance 3D |
| `bushesPerArea=3` | 2 por setor (arbusto de comida) |
| `totalRocks=32`, `goldOres=7` | 40 rochas, 12 ouros espalhados pelo mapa todo |
| Árvores fora do rio e deserto | `MapRules.canPlaceTree` |
| Rio central horizontal, `riverWidth=724` | água Terrain no Z central, 26 studs de largura |
| `waterCurrent=0.0011`, aceleração X | `RiverFlow`, corrente +X, natação lenta; valores em studs/s |
| `keepInWorld` | 4 barreiras invisíveis + correção no servidor, sem precipício |
| Snow north, desert south | `Terrain:FillBlock` com Snow/Grass/Sand |
| Wolf ID 4, hostil e perseguidor | `Wolves.luau`, 7 lobos com 3D, golpes e respawn |
| Wolf Pack compartilhamento de alvo | IA básica sem formação tática avançada; próximo passo |

**Nota de fidelidade:** trata-se de um port adaptado do gerador, não uma cópia 1:1 de todos os números, distâncias, criaturas ou regras originais. O rio usa água visual/colisão nativa e fluxo por física em Luau. Nenhuma ponte existe nesta fase.

Árvores, arbustos, rochas e ouro são recursos naturais permanentes; lobos são criaturas com vida e podem reaparecer.

## Atualização de combate e matilha
- A seleção exata de modelos por clique foi substituída por um cone de golpe (posição do avatar + direção do cursor) resolvido e validado no servidor Roblox.
- O lobo mantém a IA hostil e agora compartilha perseguição por alguns segundos com vizinhos próximos, usando agrupamento de alvos; não é uma reprodução completa de todos os comportamentos do `wolf_pack.lua`.
- Árvores e pedras são indexadas em uma grade espacial para consulta rápida de colisões dos lobos, já que esses recursos não desaparecem.
- Comida coletada ou obtida ao caçar pode curar, enquanto a vida do personagem é gerenciada pelo Humanoid e validada no servidor.

## Construções 3D da fase atual
- Parede (10 madeiras, até 30), espinhos (20 madeiras + 5 pedras, até 15) e moinho (50 madeiras + 10 pedras, até 5) são construções autoritativas do servidor, com vida e proprietário.
- Moinhos rendem +2 ouros a cada 4 segundos; espinhos atacam criaturas e jogadores que não sejam donos. Lobos contornam ou atacam obstáculos construídos.
- Uma construção pode ser destruída e consumir recursos; **árvores, rochas, ouro e arbustos não têm HP, não são destruídos nem reaparecem**.
- O catálogo de custos e modelos foi ajustado para a escala Roblox; ainda não é a conversão integral do catálogo de itens do Moo-IO.

## Armas 3D / PvP

Adicionadas marreta, machado e espada. A Tool permanece no personagem padrão R15; o `Avatar.luau` troca apenas suas peças 3D. O servidor valida desbloqueio por idade, alcance, velocidade e dano, e o módulo `Melee.luau` também reconhece adversários vivos dentro do cone frontal, respeitando o `ForceField` inicial. Os custos e danos são uma adaptação do protótipo, ainda não uma conversão 1:1 dos valores do Moo-IO Lua.
