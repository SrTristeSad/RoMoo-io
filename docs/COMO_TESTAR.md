# RoMoo io - Como testar a nova versão

1. Baixe o ZIP da última compilação verde em GitHub Actions, extraia `RoMoo-io-Teste.rbxlx` e abra no Roblox Studio.
2. Pressione **F5**. O jogo deve exibir personagem R15 com marreta, várias árvores e arbustos, pedras e ouro.
3. Use **WASD**, mova o **mouse para mirar**, segure o clique para coletar. Árvores, arbustos, pedras e ouro **não quebram**, não têm vida nem respawn.
4. Siga até o centro do mapa. Atravesse o **rio sem ponte** nadando; a água empurra para a **direita do mapa (+X)** e diminui a velocidade.
5. Explore o norte nevado e o sul desértico. A neve desacelera o jogador.
6. Ande até a borda: paredes invisíveis devem impedir que o personagem caia. Se algo o derrubar abaixo do mapa, o servidor o reposiciona.
7. Encontre lobos. Eles possuem corpo 3D, perseguem, atacam e podem ser derrotados com a marreta (não são recursos permanentes).
8. No Command Bar do **servidor** em Play, execute `tests/StudioWorldSmokeTest.luau`. Verifique mensagens PASS e o painel **Saída**.

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
- [ ] Lobos 3D aparecem e perseguem jogadores.
- [ ] Modelos naturais dão recursos indefinidamente.
- [ ] Câmera em terceira pessoa e mouse para mirar.
- [ ] Sem erros vermelhos no console.

A compilação de scripts não substitui testar a jogabilidade no Roblox Studio.
