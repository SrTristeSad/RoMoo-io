# Checklist de validação da versão 0.7 no Roblox Studio

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
