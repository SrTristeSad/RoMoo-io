# RoMoo io — roadmap orientado à fidelidade

## 0.1 — Fundação
- [x] Lua/Luau sincronizados por Rojo, estrutura separada do ToonRoyale
- [x] Mapa simples, inventário e PvP iniciais
- [ ] Validação em Roblox Studio

## 0.2 — Núcleo clássico (código implementado; teste pendente)
- [x] Clique e espaço para usar equipamento, seleção 1–9
- [x] E automático, Q comida, X travar rotação
- [x] Barra visual com 9 itens e interface de toque
- [x] Coleta e combate direcionais, com verificação no servidor
- [x] Moinhos gerando ouro periodicamente
- [x] Idades + opções de evolução no início da partida
- [x] Paredes, espinhos e moinho posicionados em frente ao personagem
- [x] Animais com perseguição/fuga e caça para obter comida
- [x] Minimap básico com posição dos jogadores
- [ ] Testes manuais PC/celular e correção de bugs

## 0.3 — Cenário autoral e fidelidade de conteúdo
- [x] Tufos de grama, flores, pedras decorativas, pinheiros de neve e cactos, sem colisão
- [x] Árvore com copas em camadas e coloração adaptada aos biomas
- [x] Minimap diferenciando neve, campo verde e deserto
- [x] Grade antiga opcional/desativada; densidade de decoração configurável
- [ ] Testes de FPS e legibilidade no Roblox Studio em celular
- [ ] Desenhar personagens e armas .io em 3D autoral
- [ ] Expandir biomas, lago/rios, comportamento animal, drops e encontros especiais
- [x] Oito estágios de escolha dos equipamentos (idades 2–9), com duas opções por estágio
- [x] Armas e defesas adicionais: machados pesados, lanças, martelos, muralhas, armadilhas e moinhos melhorados
- [ ] Fidelidade exata das árvores de equipamentos, valores e regras ao jogo de referência (não confundir com protótipo implementado)
- [ ] Placares avançados, marcadores no minimapa e mapa de equipes

## 0.4 — Combate e feedback visual
- [x] Efeitos de ataque, impacto, coleta, construção e cura executados no cliente
- [x] Números flutuantes de recursos, dano e regeneração
- [x] Animação de caminhada dos animais sem esqueleto e reação ao dano
- [x] Seleção visual de comida e construções na mão do personagem
- [x] Cooldown de comida separado de ataque e construção
- [x] Efeitos enviados apenas para jogadores próximos
- [ ] Testar efeitos e cooldown de cura durante PvP no Roblox Studio

## 0.5 — Evolução, arsenal e construções
- [x] Escolhas de idade 2–9 e desbloqueio validado no servidor
- [x] 21 itens configurados; no máximo 13 obtidos em uma partida
- [x] Barra responsiva de até três linhas mostrando todos os itens obtidos
- [x] Plataforma de cura, armadilha de lentidão e produção por moinhos melhorados
- [x] Proteção contra escolhas forjadas e itens não desbloqueados
- [ ] Testar evolução, uso e interface no Studio (PC e mobile)

## 0.6 — Clãs e PvP protegido (código implementado; teste pendente)
- [x] Clãs temporários por código de seis dígitos, gerado pelo servidor
- [x] Até oito membros, liderança transferida ao sair, clãs removidos quando vazios
- [x] Painel recolhível no cliente e indicação no minimapa e nome
- [x] Sem PvP e ataques a construções de aliados; armadilhas não atingem aliados
- [x] Plataforma de cura atende aliados do proprietário
- [x] Bloqueio de golpes através das paredes
- [x] Armadilhas de lentidão renovam o efeito preservando a velocidade original
- [ ] Testes de dois clientes, colisões, segurança, clãs e reconexão no Roblox Studio

## 0.7 — Port Moo IO Lua e terceira pessoa
- [x] Identificar fonte de referência Moo-IO / ToonRoyale-Assets android/server-lua
- [x] Portar parâmetro de ângulo de coleta (mira + cone) e conservar servidor autoritativo
- [x] Desgaste visual e quebra/respawn de árvores, rochas, arbustos e minério
- [x] Câmera de terceira pessoa usando controles Roblox nativos e raycast sob o cursor
- [x] Interface mais compacta, ajuda temporária e minimapa menor
- [x] Fauna procedimental 3D em oito espécies com IDs de referência
- [ ] Portar demais módulos do servidor Lua: catálogo completo, projéteis, física, IA avançada, tribos, chefes, rios e demais mecânicas
- [ ] Testes reais de câmera, mira e colisão no Roblox Studio

## 0.8 — Armas de longo alcance e deslocamento animal
- [x] Arco desbloqueado automaticamente na idade 6 (sem remover progressão anterior)
- [x] Flechas com munição consumida no servidor, cadência própria e limites antiabuso
- [x] Projéteis 3D por raycast, colisão com paredes/árvores e dano em animais, jogadores e construções
- [x] Aliados preservados da lógica de dano do arco
- [x] Animais 3D desviam de recursos e estruturas por steering leve
- [x] Atalho T para o item 14 da hotbar
- [ ] Validação de flechas e pathing em dois clientes no Roblox Studio

## 0.85 — Fauna 3D integrada ao jogo real (código implementado; teste pendente)
- [x] Ativar sete espécies no place: vaca, porco, ovelha, touro, touro alfa, javali e yeti
- [x] Evitar duplicar o lobo, que permanece no sistema próprio
- [x] Integrar animais ao cone de mira, HUD, dano, comida, XP e respawn
- [x] Corrigir surgimento/movimentação no rio; indexar obstáculos estáticos para reduzir custo de IA
- [x] Permitir importar malhas 3D para Cow/Bull/Sheep (fallback procedural)
- [x] Substituir smoke test antigo que exigia quebra de recursos por teste de coleta infinita
- [ ] Validar todas as espécies, combate, FPS e respawn no Roblox Studio

## 0.86 — Colisao de ataques e fauna otimizada (codigo implementado; teste pendente)
- [x] Lobo, touro, javali e yeti nao causam dano atraves de parede/tronco solido
- [x] Parede e tronco bloqueiam golpes diretos, espinhos sem colisao nao bloqueiam
- [x] Mira 3D deixa de ignorar alvos por limite artificial de partes de malhas
- [x] Animação procedimental suaviza viradas dos animais
- [x] Animais distantes atualizados com menor frequencia; alvos de jogadores avaliados uma vez por ciclo
- [x] Teste de linha de visao isolado e verificacoes na CI
- [ ] Validar linha de visao, duas maquinas e FPS real no Roblox Studio

## 0.9 — Multiplayer robusto
- [ ] Integração de chat com políticas do Roblox, proteção de spawn
- [ ] Exploits, colisões, ping e resistência a ataques automatizados
- [ ] Otimizações de dispositivos móveis / limite de construções

## 1.0 — Lançamento
- [ ] Teste com jogadores, arte original e UX final
- [ ] Monetização preferencialmente cosmética, sem vantagem competitiva
- [ ] DataStore para cosméticos/metaprogressão, não para runs temporárias
