# Checklist de validação da versão 0.2 no Roblox Studio

**Status:** PENDENTE — não foi executado dentro do Studio nesta conversa.

## Inicialização
- [ ] Abrir o Place construído pelo Rojo sem erro de sincronização.
- [ ] Sem erros vermelhos na janela Output do cliente e do servidor.
- [ ] O mapa inclui vegetação, rochas, ponto central, regiões de neve e deserto e grade.
- [ ] Avatares são arredondados e exibem nome, barra de vida e ferramenta.
- [ ] HUD aparece corretamente no PC e emulação de celular.

## Ciclo principal
- [ ] Selecionar marreta (1), apontar e clicar numa árvore, rocha e arbusto: ganhar o recurso certo.
- [ ] Repetir até recurso desaparecer e reaparecer após tempo configurado.
- [ ] Selecionar parede (3), coletar madeira, posicionar sem sobreposição; custo debitado.
- [ ] Selecionar espinhos (4) e tentar construir sem os materiais: deve negar.
- [ ] Selecionar moinho (5) e ver ouro subir a cada segundo.
- [ ] Tentar construir mais de 7 moinhos: deve negar.
- [ ] Coletar XP até idade 2, escolher machado ou espada, confirmar desbloqueio.
- [ ] Verificar que opção não escolhida continua bloqueada.
- [ ] Subir idade 3 e escolher biscoito ou parede de pedra.

## Combate e segurança
- [ ] Testar com dois jogadores: dano somente dentro do alcance e arco frontal.
- [ ] Espinhos do próprio jogador não devem causar dano ao dono.
- [ ] PvP registra abate e XP; morto renasce com idade e inventário reiniciados.
- [ ] Dois jogadores não conseguem usar construções um do outro sem destruí-las.
- [ ] Remotes rejeitam itens bloqueados, tipagens inválidas e abuso de cadência.
- [ ] Jogo não bloqueia cliente sem recursos, sem vítimas ou ao morrer.

## Controles e mobile
- [ ] WASD, mouse, espaço, E, Q, X e 1–9 respondem.
- [ ] Barra funciona por clique e por teclado.
- [ ] Joystick de toque não é bloqueado por elementos do HUD.
- [ ] Botões USAR e COMER não ficam sob interface do sistema.
- [ ] Mira e câmera funcionam em tela 16:9 e 19.5:9.

## Performance
- [ ] Monitorar uso de memória e número de partes.
- [ ] Testar destruição, respawn e 2–10 moinhos ativos simultaneamente.
- [ ] Testar entrada/saída de jogadores sem vazamento perceptível de conexões/eventos.
- [ ] Testar vacas e ovelhas fugindo do jogador; touros e lobos perseguindo e causando dano.
- [ ] Testar caça concedendo comida e XP; animal reaparecendo após o intervalo.
- [ ] Importar Cow.gltf, Bull.gltf, Wolf.gltf e Sheep.fbx e colocá-los em ServerStorage/RoMooAnimalModels.
- [ ] Verificar se os quatro animais passam a usar as malhas 3D e se a escala/rotação está correta.
- [ ] Validar que modelos importados não bloqueiam o movimento e que as barras de vida continuam funcionando.
- [ ] Verificar marcadores do minimapa se movendo e removendo jogadores desconectados.

Preencha esta lista apenas com resultados reais do Studio; não considerar tudo aprovado por inspeção do código.
