# RoMoo io - Como testar a nova versão

1. Baixe o ZIP da última compilação verde em GitHub Actions, extraia `RoMoo-io-Teste.rbxlx` e abra no Roblox Studio.
2. Pressione **F5**. O jogo deve exibir personagem R15 com marreta, várias árvores e arbustos, pedras e ouro.
3. Use **WASD**, mova o **mouse para mirar**, segure clique esquerdo para golpear. **Não precisa acertar exatamente o pixel da árvore:** o servidor escolhe um alvo à frente dentro do alcance. Árvores, arbustos, pedras e ouro **não quebram**, não têm vida nem respawn.
4. Siga até o centro do mapa. Atravesse o **rio sem ponte** nadando; a água empurra para a **direita do mapa (+X)** e diminui a velocidade.
5. Explore o norte nevado e o sul desértico. A neve desacelera o jogador.
6. Ande até a borda: paredes invisíveis devem impedir que o personagem caia. Se algo o derrubar abaixo do mapa, o servidor o reposiciona.
7. Encontre lobos. Eles possuem corpo 3D, perseguem, **avisam lobos próximos**, atacam e podem ser derrotados com a marreta. Ao morrerem, fornecem comida. **Os lobos são criaturas, não recursos naturais permanentes.**
8. Após perder vida para um lobo, colete comida nos arbustos e pressione **Q** para curar (10 comidas, até 32 pontos de vida, intervalo de 1,25 s). No celular, use **CURAR**.
9. Acompanhe a **barra de XP e idade** abaixo do inventário. Após 20 golpes de recurso (+5 XP por golpe), alcance idade 2 e libere os espinhos. Na idade 3, libere o moinho; na 4, libere o muro de pedra. Ao desbloquear, aparece um aviso.
10. Teste a barra: **1 marreta**, **2 parede (10 madeiras)**, **3 espinhos (20 madeiras + 5 pedras)**, **4 moinho (50 madeiras + 10 pedras)** e **5 muro de pedra (30 pedras + 10 madeiras)**. Botões bloqueados informam a idade necessária. O moinho produz **2 ouros a cada 4 segundos**. Construções podem ser destruídas, mas recursos naturais nunca.
11. No Command Bar do **servidor** em Play, execute `tests/StudioWorldSmokeTest.luau`, `tests/StudioMeleeHealingSmokeTest.luau`, `tests/StudioBuildingSmokeTest.luau` e `tests/StudioProgressionSmokeTest.luau`. Verifique mensagens PASS e o painel **Saída**.

## Modelos gratuitos da Creator Store (opcionais)

O jogo funciona com recursos 3D procedurais mesmo sem importar assets. Para trocar por modelos publicados na Creator Store:

- Árvore Low-Poly gratuita: https://create.roblox.com/store/asset/3287226226/LowPoly-Tree
- Lobo gratuito: https://create.roblox.com/store/asset/12181904793/Wolf (contém scripts e várias malhas; use somente a geometria).

**No Studio, fora do Play**, use View/Exibir > Command Bar e execute:

```lua
require(game:GetService("ServerScriptService").RoMoo.CreatorAssets).install()
```

A importação usa o novo `AssetService:LoadAssetAsync`, apaga scripts dos modelos e salva geometria em `ServerStorage/RoMooResourceModels/Tree` e `ServerStorage/RoMooAnimalModels/Wolf`. Se o Studio recusar assets de terceiros, veja as permissões de experiência e confirme que são modelos livres. Alternativamente, use a Caixa de ferramentas/Creator Store, insira os modelos, **remova qualquer Script/LocalScript/ModuleScript** e mova-os para as pastas acima.

Depois salve o place no Studio. **O ZIP pronto não incorpora automaticamente malhas de terceiros:** a importação depende do acesso da sua conta Roblox.

## O que procurar na versão atual

- [ ] Rio reto com correnteza para +X, sem pontes.
- [ ] Neve norte, grama centro, deserto sul.
- [ ] Pelo menos ~170 árvores e ~45 arbustos distribuídos em setores.
- [ ] Pedras e ouro também podem aparecer no rio.
- [ ] Quatro limites invisíveis impedem sair do mapa.
- [ ] Lobos 3D aparecem, perseguem, avisam a matilha e desviam de árvores.
- [ ] Golpes direcionais acertam recursos mesmo sem clique exato na malha, mas não alcançam alvos atrás/fora do cone.
- [ ] Q consome 10 alimentos e cura até 32 de vida; botão CURAR também funciona no celular.
- [ ] HUD mostra vida atual e máxima.
- [ ] Hotbar 1–5 e clique selecionam marreta, parede, espinhos, moinho e muro de pedra.
- [ ] A idade começa em 1; coleta dá XP e faz subir de idade.
- [ ] Idade 2 desbloqueia espinhos; 3 desbloqueia moinho; 4 desbloqueia muro de pedra.
- [ ] A tentativa de construir antes da idade exigida é rejeitada pelo servidor.
- [ ] O muro de pedra é mais resistente do que a parede de madeira.
- [ ] Parede custa 10 madeiras, espinhos 20 madeiras + 5 pedras, moinho 50 madeiras + 10 pedras, muro 30 pedras + 10 madeiras.
- [ ] Construções não podem ser colocadas dentro do rio, em recursos naturais ou na área de nascimento.
- [ ] Espinhos causam dano a lobos e adversários; não ferem o dono.
- [ ] O moinho paga 2 ouros a cada 4 segundos enquanto pertence a um jogador na partida.
- [ ] Estruturas têm vida e podem ser destruídas, mas recursos naturais continuam permanentes.
- [ ] Lobos desviam de construções ou atacam paredes quando a passagem está fechada.
- [ ] Modelos naturais dão recursos indefinidamente.
- [ ] Câmera em terceira pessoa e mouse para mirar.
- [ ] Sem erros vermelhos no console.

A compilação de scripts não substitui testar a jogabilidade no Roblox Studio.
