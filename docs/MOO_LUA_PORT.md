# Migração do servidor Moo IO Lua para RoMoo io (Roblox)

## Fonte correta

- Projeto original do usuário: https://github.com/SrTristeSad/Moo-IO
- Cópia com port do servidor Lua: https://github.com/SrTristeSad/ToonRoyale-Assets/tree/main/android/server-lua
- Referência local: `android/server-lua/world/` (servidor Lua, não Node.js/V2 privado)
- Destino Roblox: `src/server/*.luau`, `src/shared/Config.luau`, `src/client/`
- **Não modificar** Moo-IO nem ToonRoyale-Assets; desenvolver apenas no RoMoo-io.

## Status de fidelidade

| Referência Lua | Roblox atual | Estado |
| --- | --- | --- |
| `world/gather.lua` | `Game.server.luau`, `World.hitNode` | Coleta por golpe / mira angular portadas; durabilidade é uma adaptação Roblox solicitada |
| `world/objects.lua` | `World.luau`, `WorldDecor.luau` | Geração 3D adaptada, contagem/escala diferentes |
| `world/animal_types.lua` | `Animals.luau`, `AnimalModels.luau` | 8 espécies visuais 3D, SourceTypeId preservado |
| `world/animal_health.lua`, `animal_rewards.lua` | `Animals.hit` | Combate/caça adaptados; não paridade 1:1 |
| `world/weapon_tick.lua`, `world/economy.lua` | `Game.server.luau`, `Config.luau` | Cooldown e economia próprios; catálogo completo pendente |
| `world/tribes.lua` | `Clans.luau` | Clãs temporários adaptados, não protocolo original |
| `world/projectiles.lua` | `Projectiles.luau`, `Game.server.luau` | Projéteis 3D server-authoritative por raycast; ainda não há armas de fogo, veneno, reflexões nem protocolo original |
| `world/collision.lua`, `movement.lua` | física nativa Roblox | adaptação, não port literal |
| `world/ai.lua`, `crab_king.lua` | `Animals.luau` | IA básica com steering de obstáculos; chefes complexos pendentes |
| WebSocket, MessagePack, HMAC do servidor Lua | RemoteEvents Roblox | substituídos pela rede/autenticação nativa Roblox |
| `world/room.lua`, `game_loop.lua` | `Game.server.luau` | integração por funções/serviços, paridade incompleta |

**Não declarar que o servidor original inteiro foi migrado:** o sistema Roblox tem APIs de física, rede, câmera, avatares e instâncias diferentes. Um port completo requer adaptação e teste módulo a módulo.

## Licenças

O código de referência Moo IO, incluindo o port do servidor Lua, é marcado `SPDX-License-Identifier: AGPL-3.0-only`. O servidor Node upstream do `al007ex/moomoo-clone` inclui código Apache-2.0, preservado no NOTICE original. A migração derivada exige cumprir os avisos e as obrigações da licença AGPL, inclusive disponibilização de fonte na utilização em rede quando aplicável.

- `LICENSE`: GNU AGPL 3.0 (copiada de Moo-IO)
- `licenses/upstream-server-APACHE-2.0.txt`: licença do servidor upstream
- `NOTICE.md`: origem e mudanças para Roblox
- Modelos Quaternius CC0 com procedência documentada em `docs/IMPORTAR_ANIMAIS_3D.md`.

O RoMoo io não é um produto oficial nem afiliado ao MooMoo.io ou seus titulares.

## Critérios para próxima fase

1. Terceira pessoa e quebra de recursos funcionando com mouse e dispositivos móveis.
2. Nenhuma regressão no combate PvP, flechas, armazenamento temporário, itens, clãs e animações.
3. Melhorar IA 3D, colisão e feedback em multiplayer.
4. Portar módulos restantes e executar testes comparativos contra servidor Lua de origem.
