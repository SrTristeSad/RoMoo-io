# Clãs e combate — RoMoo io 0.6

## Experiência

- O jogador toca em **CLÃ: SOLO**, perto da parte superior esquerda, para abrir o painel.
- **CRIAR** gera automaticamente um código numérico de **6 dígitos**. Não é necessário digitar nada.
- Para convidar alguém, compartilhe o código. O outro jogador digita os seis dígitos e clica **ENTRAR**.
- O grupo tem até **8 jogadores**, e cada jogador só pode pertencer a um grupo por vez.
- **SAIR** libera a vaga. O líder passa a liderança a outro membro ativo; o grupo é removido quando o último sair.
- Os clãs são **temporários por servidor**; não são persistidos entre partidas e não usam DataStore.

O servidor gera códigos numéricos para evitar mostrar nomes de clã enviados livremente por jogadores sem filtragem. Nomes livres, quando implementados, **exigirão filtragem de texto conforme as regras do Roblox**.

## Efeitos no jogo

- Aliados aparecem com cor verde no minimapa e tag [CÓDIGO] no nome; o jogador local continua azul.
- Golpes PvP não atingem aliados.
- Os ataques não visam estruturas construídas por aliados.
- Espinhos e armadilhas não danificam nem reduzem velocidade de aliados.
- Pads de cura podem restaurar a vida de aliados próximos.
- Muralhas sólidas bloqueiam ataques a jogadores, animais e recursos localizados atrás delas.
- A lentidão das armadilhas usa prazo de expiração renovável, preservando o WalkSpeed original.

## Limitações técnicas

- Não há convites privados, senhas, expulsão de membros ou hierarquias de permissões.
- A liderança é transferida na saída do líder, mas não há ferramentas de moderação dentro do clã.
- O efeito de lentidão não substitui um sistema completo de status: outros buffs futuros deverão ser integrados de forma centralizada.
- A verificação de cobertura usa Raycast com apenas os modelos de paredes sólidas.
- A versão não substitui testes de latência e integridade no Roblox Studio.

## Roteiro de testes multiplayer

Use **Test > Server & Clients**, com **dois** ou mais clientes. A checklist de referência está em `docs/TEST_CHECKLIST.md`.

1. Cliente A cria clã e copia o código; B entra pelo código.
2. A e B tentam se atacar com marretas e espadas.
3. A coloca uma parede e espinhos, B tenta destruir a parede e atravessar espinhos.
4. Criar uma plataforma curativa; com B ferido, testar alcance e cura.
5. Sair do clã, testar hostilidade novamente e transferência de liderança.
6. Com dois jogadores inimigos, testar ataque através de parede, com e sem obstáculos.
7. Fazer B entrar em uma armadilha, sair, reentrar e verificar que a velocidade retorna.
8. Simular desconexão de jogadores e entrada de um terceiro; verificar estado correto dos clãs.
9. Repetir no emulador mobile; confirmar que painel de clãs não interfere no joystick.

**Importante:** não marcar nenhum teste como aprovado até executá-lo no Studio. Nenhuma monetização foi integrada nesta versão.
