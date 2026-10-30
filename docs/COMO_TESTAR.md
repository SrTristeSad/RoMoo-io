# Teste direto — protótipo 3D da marreta

Abra o `.rbxlx`, clique em **Continuar** se o Studio exibir aviso de migração de iluminação (é um aviso do Studio, não erro do projeto), e pressione **F5**.

## Conferir visual
- [ ] O personagem é o **avatar Roblox padrão**, não uma bola.
- [ ] A **marreta aparece na mão** ao nascer.
- [ ] O chão usa **Terrain Grass** e há um rio azul com ondas, margens de areia e **três pontes de madeira**.
- [ ] Árvores têm tronco e folhagem; pedra tem formas angulares; ouro tem veios dourados.

## Conferir ação
- [ ] WASD e câmera do Roblox em terceira pessoa funcionam.
- [ ] Aproximar da árvore destaca seu contorno amarelo quando o cursor está sobre ela.
- [ ] Clicar com a marreta dá +5 madeira **por golpe**, mesmo após 20, 50 ou 100 golpes; a árvore continua no lugar.
- [ ] Pedra dá +5 pedra por golpe e nunca desaparece.
- [ ] Minério dá +3 ouro por golpe e nunca desaparece.
- [ ] Não existe respawn para esses recursos: todos permanecem presentes o tempo inteiro.
- [ ] A marreta não minera um recurso distante, nem ataca rápido demais.
- [ ] Segurar clique repete golpes e anima a marreta a cada coleta.
- [ ] Números flutuantes +5/+3 aparecem no recurso e o contador do HUD aumenta.
- [ ] Mirar nas folhas, na rocha ou nos veios de ouro permite selecionar o recurso 3D.
- [ ] Rio permite natação e as três pontes permitem travessia a pé.
- [ ] HUD mostra apenas madeira, pedra e ouro. Não há painel de clãs nem dezenas de itens.

## Conferir console
- [ ] Não há erro vermelho de servidor/cliente.
- [ ] O console do servidor exibe `[RoMoo 3D] Marreta equipada...`.
- [ ] Executar `tests/StudioWorldSmokeTest.luau` no servidor resulta em PASS.

A compilação automática **não substitui** os testes reais do Play no Studio.
