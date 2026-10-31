# Checklist de validação da versão 0.8 no Roblox Studio

**Status:** PENDENTE — não foi executado dentro do Studio nesta conversa.

## Câmera 3ª pessoa, HUD e coleta
- [ ] Abrir um place novo da CI com F5; personagem deve aparecer em terceira pessoa atrás do personagem, não de cima.
- [ ] Roda do mouse aproxima/afasta (12–24 studs); botão direito orbita a câmera; WASD continua funcionando.
- [ ] Aproximar da árvore, apontar com o cursor e segurar botão esquerdo: madeira aumenta por golpe.
- [ ] Depois de alguns golpes, a barra de durabilidade aparece e o recurso desaparece ao quebrar.
- [ ] Após 18 segundos, o mesmo tipo de recurso reaparece no local.
- [ ] Repetir para pedra, veio de ouro e arbusto: cada um concede o recurso correto.
- [ ] Confirmar que a ajuda some após 7 segundos e o HUD não encobre personagem nem o centro.
- [ ] Confirmar que clãs, hotbar de 13 itens e mobile não tiveram regressão.
- [ ] Verificar oito espécies 3D sem precisar importar .FBX/.glTF.
- [ ] Executar `tests/StudioResource3DTest.luau` no servidor para validar desgaste/animais.

## Inicialização
- [ ] Abrir o Place construído pelo Rojo sem erro de sincronização.
- [ ] Sem erros vermelhos na janela Output do cliente e do servidor.
- [ ] O mapa inclui grama em tufos, flores, pedras, pinheiros e cactos; regiões de neve/deserto; a grade antiga fica oculta.
- [ ] As árvores têm copas em camadas e usam paletas diferentes nos biomas.
- [ ] A decoração não impede coletar, atacar ou construir e não bloqueia a passagem.
- [ ] O minimapa diferencia visualmente as três regiões.
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
- [ ] Alcançar idades 4–9 e escolher um dos dois itens em cada fase.
- [ ] Item rejeitado em cada escolha continua bloqueado.
- [ ] Confirmar que todas as escolhas são aplicadas em ordem, sem pular idades via Remote.
- [ ] Testar novas armas, alcance, coleta e dano de cada uma.
- [ ] Construir plataforma curativa, armadilha, muralha, espinhos de pedra e moinhos superiores.
- [ ] Verificar regeneração do pad, dano/redução de velocidade da armadilha e ouro dos moinhos.
- [ ] Confirmar retorno da velocidade normal após a armadilha e após respawn.
- [ ] Verificar todos os 13 itens obtidos visíveis e selecionáveis pelo HUD (desktop e celular).
- [ ] Executar `tests/StudioProgressionSmokeTest.luau` no Studio e registrar a saída.

## Clãs e PvP cooperativo
- [ ] Testar com 2 clientes no Studio. A cria clã e recebe um código de 6 dígitos.
- [ ] B entra com esse código; ambos aparecem com a tag e cor verde de aliado no minimapa.
- [ ] A golpeia B e tenta destruir sua parede: dano negado.
- [ ] B pisa nos espinhos e na armadilha de A: não deve sofrer dano nem lentidão.
- [ ] O pad de A cura B enquanto estiver no alcance; jogador sem clã não recebe cura.
- [ ] B sai; A consegue causar dano em B novamente.
- [ ] Código não encontrado, formato inválido, clã com 8 membros e spam de pedidos rejeitados.
- [ ] Ao sair o líder, a liderança é transferida; quando o último jogador sai, o código deixa de existir.
- [ ] Ao morrer, o jogador mantém o clã, mas perde recursos e progresso.
- [ ] A interface de clãs não cobre as ações principais no celular.

## Arco e animais 3D — versão 0.8
- [ ] Idade 6 desbloqueia o ARCO sem alterar uma das duas escolhas de upgrade.
- [ ] Usar arco com 0 madeira é rejeitado; com 2 madeiras cada disparo consome exatamente 2.
- [ ] Segurar clique gera flechas no máximo a cada 0,85 s (servidor e cliente).
- [ ] Flecha acerta animal 3D, reduz vida e concede comida + XP se abater.
- [ ] Flecha não atravessa parede sólida nem rocha, e não coleta madeira com arco.
- [ ] Flecha atinge jogador inimigo sem ForceField, mas não causa dano em aliado do clã.
- [ ] Flecha destrói construção inimiga depois de dano suficiente, mas não estrutura aliada.
- [ ] Flechas são removidas depois do alcance e não acumulam no Workspace.
- [ ] O jogador seleciona o 14º item pelo atalho T e pelo botão da barra.
- [ ] Verificar que lobos, touros, porcos e ovelhas não atravessam troncos nem muralhas.
- [ ] Executar `tests/StudioProjectileTest.luau` na Command Bar do servidor.

## Renascimento e protecao inicial (revisao de outubro de 2026)
- [ ] Com dois clientes, jogador A nasce com ForceField por 3 segundos; B nao deve feri-lo.
- [ ] Enquanto o ForceField estiver ativo, A nao pode atacar/colher/derrubar estruturas.
- [ ] Apos 3 segundos, A consegue atacar e colher normalmente.
- [ ] A evolui ate idade 5, usa espada, acumula madeira/pedra/ouro/comida e constroi parede e moinho.
- [ ] B derrota A: o placar de mortes sobe uma vez; idade e XP voltam ao inicio; inventario zera e a espada fica bloqueada.
- [ ] As estruturas de A somem ao morrer, inclusive moinhos que geravam ouro.
- [ ] Ao renascer, a marreta funciona e o HUD volta a selecionar uma opcao desbloqueada.
- [ ] Abates e mortes da sessao permanecem no placar.
- [ ] Ao sair da partida, bases e moinhos do jogador desconectado sao removidos.
- [ ] Rodar `tests/StudioSessionStateSmokeTest.luau` na Command Bar do servidor.

## Fauna 3D integrada — sete novas especies (sem duplicar lobos)
- [ ] Vaca, porco e ovelha aparecem no campo, com formas 3D visiveis.
- [ ] Touro, touro alfa e javali perseguem; yeti aparece na neve.
- [ ] Fauna nao nasce dentro do rio nem caminha atraves dele.
- [ ] Rebanhos desviam de arvores, pedras e construcoes.
- [ ] Segurar o ataque causa dano a vacas e outros animais, com alimento e XP no abate.
- [ ] Animais mortos reaparecem apos 24 segundos sem duplicatas.
- [ ] Lobo antigo permanece independente, com dano e espinhos inalterados.
- [ ] Apos importar Cow/Bull/Sheep em ServerStorage/RoMooAnimalModels, a malha real e exibida.
- [ ] Executar `tests/StudioResource3DTest.luau` na Command Bar do servidor.
- [ ] Monitorar FPS com 2 clientes, mapa cheio e 20 ou mais animais.

## Animacao das patas e otimizacoes de recursos
- [ ] Abrir jogo no Studio: vacas, porcos, ovelhas e lobos movem pernas ao andar.
- [ ] Cascos/patas acompanham as pernas sem se desprender do corpo.
- [ ] Animais parados voltam a pose de descanso.
- [ ] Importacao de Cow/Bull/Sheep/Wolf nao quebra o movimento do animal.
- [ ] Arvores/rochas/arbustos continuam coletaveis mesmo com detalhes CanQuery=false.
- [ ] Mouse consegue mirar no tronco de arvores, nao apenas na copa.
- [ ] Validar sombra e taxa de quadros com 100+ arvores no PC e mobile.
- [ ] Rodar `tests/StudioCreatureGaitSmokeTest.luau` no Server Command Bar.

## Fauna e golpes: paredes, FPS e viradas
- [ ] Com vaca atras de muro, marreta nao acerta atraves da parede.
- [ ] Contra vaca sem muro, coleta de alimento e XP continua funcionando.
- [ ] Lobo, javali e touro nao causam dano ao jogador atras do muro.
- [ ] Espinhos sem colisao nao bloqueiam visao dos animais.
- [ ] Arvores e rochas solidas bloqueiam ataques de proximidade.
- [ ] Animais distantes de jogadores atualizam posicao com menor frequencia.
- [ ] Girar repetidamente perto da fauna: nao deve ter rotacao brusca.
- [ ] Validar no servidor `tests/StudioCombatVisibilitySmokeTest.luau`.
- [ ] Medir FPS e memoria em PC e emulador mobile.

## Combate e segurança
- [ ] Golpe contra jogador/animal atrás de muralha não atravessa a parede.
- [ ] Armadilha de lentidão reaplicada não deixa velocidade travada em 10.
- [ ] A velocidade original retorna após o último efeito expirar.
- [ ] Testar com dois jogadores: dano somente dentro do alcance e arco frontal.
- [ ] Ataque/colheita exibem pulso e número flutuante perto do alvo.
- [ ] Atacar e apertar Q imediatamente consome comida sem aguardar cooldown do ataque.
- [ ] Cura, construção e golpes não criam instâncias persistentes no Workspace do servidor.
- [ ] Com muitos jogadores atacando, verificar efeitos visuais e memória de clientes próximos.
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
- [ ] Monitorar uso de memória e número de partes; comparar `Config.Decoration.Enabled = true/false`.
- [ ] Testar diferentes quantidades de `GrassTufts` e `Flowers` sem travamento em celulares.
- [ ] Executar `tests/StudioWorldSmokeTest.luau` no Command Bar em Play, e registrar a saída.
- [ ] Verificar que a Baseplate padrão não se sobrepõe ao chão gerado.
- [ ] Testar destruição, respawn e 2–10 moinhos ativos simultaneamente.
- [ ] Testar entrada/saída de jogadores sem vazamento perceptível de conexões/eventos.
- [ ] Testar vacas e ovelhas fugindo do jogador; touros e lobos perseguindo e causando dano.
- [ ] Conferir oscilação/rotação da caminhada e ausência de tremores nas malhas importadas.
- [ ] Golpear uma vaca e verificar fuga ampliada temporariamente.
- [ ] Verificar que animais não surgem dentro de árvores ou outros animais.
- [ ] Trocar entre marreta, maçã, biscoito e construções e verificar o item exibido na mão.
- [ ] Testar caça concedendo comida e XP; animal reaparecendo após o intervalo.
- [ ] Importar Cow.gltf, Bull.gltf, Wolf.gltf e Sheep.fbx e colocá-los em ServerStorage/RoMooAnimalModels.
- [ ] Verificar se os quatro animais passam a usar as malhas 3D e se a escala/rotação está correta.
- [ ] Validar que modelos importados não bloqueiam o movimento e que as barras de vida continuam funcionando.
- [ ] Verificar marcadores do minimapa se movendo e removendo jogadores desconectados.

Preencha esta lista apenas com resultados reais do Studio; não considerar tudo aprovado por inspeção do código.
