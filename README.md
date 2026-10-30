# RoMoo io — Protótipo 3D nativo do Roblox

**Objetivo atual:** testar apenas o fundamento do MooMoo.io em terceira pessoa, usando os elementos do Roblox: **personagem padrão R15, marreta equipada, árvores, pedras, minérios de ouro, chão de Terrain e rio de água real**. Não é um mapa 2D com peças espalhadas nem um personagem substituído por esferas.

## O que foi implementado nesta versão

- Avatar Roblox normal com roupas, cabelo, animações, corpo e acessórios originais. Nada de esconder o Humanoid ou redesenhar o personagem.
- `Tool` de marreta criada com peças metálicas, madeira e empunhadura de tecido, equipada automaticamente em `Humanoid` após nascer. Corrigido material inexistente `Enum.Material.Leather` que podia impedir o equipamento.
- Câmara Roblox normal em **3ª pessoa**, roda do mouse para zoom, botão direito para orbitar, WASD para andar.
- **Terrain** do Roblox para grama com vegetação nativa. O rio usa `Enum.Material.Water`, ondas, transparência e cor configuradas, com fundo de areia e **três pontes** de madeira com acessos e corrimãos.
- Árvores com tronco e copa, rochas angulares de `WedgePart`/Slate, e minérios de ouro com veios metálicos. Todos são modelos físicos 3D do Roblox.
- Clique no recurso perto do jogador com a marreta: o **servidor valida distância, ferramenta, cooldown e linha de visão**. Cada golpe rende material, sem remover o recurso.
- **Coleta ilimitada a cada golpe, como no MooMoo.io**: árvore, pedra e minério de ouro são permanentes; sem durabilidade, destruição ou respawn.
- HUD pequena com contadores de madeira, pedra e ouro; recurso sob o cursor ganha contorno amarelo e dica de interação. O cursor usa raycast sobre os recursos 3D, e cada acerto mostra o ganho em números flutuantes.
- Recursos iniciais próximos ao spawn. Não é necessário caminhar pelo mapa inteiro para encontrar a primeira árvore ou pedra.
- Os recursos podem ser substituídos por seus próprios modelos do Creator Store: crie `ServerStorage/RoMooResourceModels` com `Model` nomeados `Tree`, `Rock`, `Gold`. O jogo usa automaticamente o template 3D importado, sem executar scripts incluídos nos modelos.

**Por enquanto, não ativamos os módulos antigos de clãs, animais, upgrades, arco e construções.** Eles continuam guardados no repositório e no histórico Git para desenvolvimento posterior. Esta versão é intencionalmente mais simples para acertar a apresentação e a coleta antes de crescer.

## Testar no Roblox Studio

1. Baixe o `.rbxlx` da execução verde mais recente em [Actions](https://github.com/SrTristeSad/RoMoo-io/actions/workflows/build-studio.yml).
2. Abra o arquivo no Roblox Studio, pressione **F5**.
3. Veja o avatar padrão segurando a marreta, posicionado perto das primeiras árvores, pedras e ouro.
4. Ande com **WASD**, aproxime-se até ficar a cerca de 17 studs, aponte o cursor para a árvore e **clique várias vezes** (ou mantenha o botão pressionado).
5. Acompanhe os contadores; continue batendo indefinidamente na mesma árvore. Repita com pedra e ouro.
6. Explore o rio de água real e atravesse qualquer uma das três pontes. A água funciona como Terrain nativo, com comportamento de natação padrão.
7. Se não funcionar, abra **Exibir → Saída** e envie a mensagem de erro e uma captura do jogo.

Para validar a geração e a coleta sem depender do cursor, execute o conteúdo de `tests/StudioWorldSmokeTest.luau` no **Command Bar do servidor**, durante Play.

## Arquivos ativos

- `src/shared/Config.luau` — três tipos de recurso, marreta e parâmetros.
- `src/server/Game.server.luau` — recebimento e validação de golpes, recompensas por acerto, **sem despawn/respawn de recursos naturais**.
- `src/server/World.luau` — Terrain, rio, ponte e modelos de recursos 3D.
- `src/server/Avatar.luau` — Tool de marreta e avatar padrão.
- `src/client/Client.client.luau` — controles, alvo destacado e HUD.
- `default.project.json` — inclui **apenas os scripts ativos** na build desta fase.

O servidor Lua do [Moo-IO](https://github.com/SrTristeSad/Moo-IO) permanece como referência de mecânicas futuras. Consulte `NOTICE.md` e `LICENSE` para créditos/licenciamento. RoMoo io é independente, sem afiliação ao MooMoo.io oficial.


## Melhorias desta revisão
- Correção de material inválido na criação da marreta.
- Cada golpe da coleta contínua aciona a animação de ataque do Roblox.
- Mira 3D por raycast filtrando recursos, sem selecionar o chão e objetos decorativos.
- Efeitos de impacto e contadores flutuantes de recompensa por jogador.
- Três pontes sobre o rio, com tábuas, acessos e corrimãos.
- Árvore, pedra e ouro permanecem após quantos golpes forem aplicados.
- Pipeline da build realiza checagens contra regressão da coleta permanente.
