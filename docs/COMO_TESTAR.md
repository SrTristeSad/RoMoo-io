# Teste direto — protótipo 3D da marreta

Abra o `.rbxlx`, clique em **Continuar** se o Studio exibir aviso de migração de iluminação (é um aviso do Studio, não erro do projeto), e pressione **F5**.

## Conferir visual
- [ ] O personagem é o **avatar Roblox padrão**, não uma bola.
- [ ] A **marreta aparece na mão** ao nascer.
- [ ] O chão usa **Terrain Grass** e há um rio azul com ondas, margens de areia e ponte de madeira.
- [ ] Árvores têm tronco e folhagem; pedra tem formas angulares; ouro tem veios dourados.

## Conferir ação
- [ ] WASD e câmera do Roblox em terceira pessoa funcionam.
- [ ] Aproximar da árvore destaca seu contorno amarelo quando o cursor está sobre ela.
- [ ] Clicar com marreta dá +5 madeira, mostra a barra de vida, e quebra após 3 golpes.
- [ ] Pedra dá +5 pedra e quebra após 4 golpes.
- [ ] Minério dá +3 ouro e quebra após 5 golpes.
- [ ] Recurso reaparece no mesmo lugar após ~12 s.
- [ ] A marreta não minera um recurso distante, nem ataca rápido demais.
- [ ] Rio permite natação e a ponte permite a travessia a pé.
- [ ] HUD mostra apenas madeira, pedra e ouro. Não há painel de clãs nem dezenas de itens.

## Conferir console
- [ ] Não há erro vermelho de servidor/cliente.
- [ ] O console do servidor exibe `[RoMoo 3D] Marreta equipada...`.
- [ ] Executar `tests/StudioWorldSmokeTest.luau` no servidor resulta em PASS.

A compilação automática **não substitui** os testes reais do Play no Studio.
