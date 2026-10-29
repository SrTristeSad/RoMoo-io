# RoMoo io

Protótipo multiplayer de sobrevivência e construção para **Roblox**, desenvolvido em **Luau**. Projeto independente: não utiliza código ou assets do MooMoo.io nem modifica o ToonRoyale original.

## Status
**MVP 0.1 (código inicial)** — terreno e recursos gerados no servidor, coleta, PvP, construções, comida/recuperação, HUD para PC e celular. Ainda **não validado em sessão real do Roblox Studio**. Sem loja, monetização ativa, DataStore ou itens pagos.

## Como abrir no Roblox Studio
O projeto usa [Rojo](https://rojo.space/) para sincronizar os scripts com o Roblox Studio.

1. Instale o Roblox Studio e a extensão **Rojo** do Studio.
2. Instale a CLI Rojo (versão compatível com a extensão).
3. Baixe/clone este repositório, abra o terminal na pasta raiz e execute `rojo serve`.
4. Abra um **Baseplate** novo no Roblox Studio, conecte o plugin Rojo ao servidor local e clique em **Play**.
5. Para testar com dois jogadores, use **Test > Server & Clients** no Studio.

Alternativa: `rojo build -o RoMoo.rbxlx` produz um arquivo de place no formato XML, que pode ser aberto no Studio.

## Controles
| Ação | PC | Celular |
| --- | --- | --- |
| Mover | WASD / padrão Roblox | Joystick Roblox |
| Coletar recurso mais próximo | E | Botão COLETAR |
| Atacar jogador/estrutura inimiga | F | Botão ATACAR |
| Comer e recuperar vida | H | Botão COMER |
| Construir parede | 1 | Botão PAREDE |
| Construir armadilha | 2 | Botão ARMADILHA |

Os recursos precisam estar perto do personagem. As ações são verificadas **no servidor**, não no cliente.

## Estrutura
- `default.project.json` — projeto Rojo.
- `src/shared/Config.luau` — configurações de balanceamento.
- `src/server/World.luau` — terreno, recursos e modelos simples.
- `src/server/Game.server.luau` — regras, segurança, inventário, combate e construções.
- `src/client/Client.client.luau` — câmera, HUD, botões e teclado.
- `docs/ROADMAP.md` — próximas versões.

## Segurança / limitações
O servidor controla inventário, cooldown, posições de construções, alcance e dano. O cliente só solicita ações. **Inventário é temporário por sessão**; a versão inicial evita DataStore para rodar sem exigir experiência publicada. Quando ativarmos salvamento, os testes no Studio precisarão de configuração apropriada de acesso à API.

## Objetivo comercial
Jogo gratuito, otimizado para desktop e celular, com cosméticos e recursos de personalização no futuro, preferencialmente sem vantagens pagas de combate.

**Observação:** O nome e os visuais de lançamento devem ser originais; o termo “MooMoo.io” é usado aqui apenas para descrever a inspiração mecânica.
