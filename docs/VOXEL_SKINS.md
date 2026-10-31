# RoMoo-io — skins de personagens cubicos

## O que a implementacao faz
- O avatar usa os controles, Humanoid, Motor6D, animacoes e sistema de PvP R15
  do Roblox, mas esconde as malhas R15 e cobre o corpo com seis cubos visuais.
- O modelo visual tem as partes `Voxel_Head`, `Voxel_Torso`, `Voxel_RightArm`,
  `Voxel_LeftArm`, `Voxel_RightLeg` e `Voxel_LeftLeg`.
- Um PNG 64x64 pode ser lido como atlas. Cada face de cubo usa
  `ImageRectOffset` e `ImageRectSize` de um `ImageLabel` em `SurfaceGui`.
- Bracos classicos = quatro pixels de largura; slim = tres.
- A camada externa e opcional e depende da transparencia do PNG.
- Quando nao ha PNG configurado, exibimos visuais originais 'Explorador'
  e 'Construtor', ambos feitos com cores e olhos cubicos.
- A aparencia e aplicada no servidor, para aparecer a outros jogadores.
- Pecas visuais sem colisao nao interferem nos golpes e na fisica.

## Colocar sua skin em 64x64
1. Crie ou obtenha um PNG de 64x64 pixels que voce tenha direito de usar.
2. Envie-o ao Roblox pelo Creator Hub (importacao de imagem) e observe a moderacao.
3. Dê permissao de uso do asset para a experiencia, se o Roblox solicitar.
4. Abra `src/shared/Config.luau`, procure `VoxelSkins.Presets`.
5. Na terceira linha (classico), troque `imageId=0` pelo ID numerico da sua imagem.
   Na quarta (slim), faca o mesmo para skins de bracos finos.
6. Compile pelo Rojo/GitHub Actions e abra o arquivo `.rbxlx` no Studio.
7. Em Play, clique em **SKIN** para alternar os visuais cadastrados.

Apenas os IDs previamente cadastrados em `Config` podem ser selecionados;
o RemoteEvent `ChooseSkin` recebe o indice e nao recebe arquivos nem URLs.
Imagens sem permissao, rejeitadas pela moderacao ou com tamanho incorreto
podem aparecer em branco.

## Geometria e limites
- A imagem e o layout modernos 64x64. PNG 64x32 legado nao e suportado.
- O movimento ainda usa juntas R15. Por isso as pernas e os bracos cubicos
  podem apresentar pequenas folgas nas articulacoes, a ajustar visualmente.
- As partes sao apenas de aparencia; a deteccao de ataque continua baseada
  nas partes R15 do Roblox.
- Cada skin PNG cria guis nas seis faces de seis cubos, mais seis cubos
  da camada extra se ativada. Verifique FPS no celular.
- O terreno ainda e Terrain nativo com bordas, grama, neve, deserto e rio.
  Nao existe sistema de minerar blocos no mapa: arvores/rochas sao infinitas.
- Os PNGs nao estao embutidos no codigo nem no pacote de modelos 3D.

## Teste
Na Command Bar do **servidor em Play**, cole
`tests/StudioVoxelSkinsSmokeTest.luau`.
Ele verifica as UVs, variacao slim, partes sem colisao e a segunda camada
sem carregar imagens externas. O visual com uma imagem real deve ser
validado manualmente em Studio.

## Diretrizes para publicacao
Estilo de cubos, layout tecnico de PNG e mecanicas originais podem ser
usados para criar um jogo com identidade propria. Nao reaproveite logo,
nome comercial, texturas e personagens oficiais de Minecraft em um jogo
publicado/monetizado sem a autorizacao aplicavel. Consulte as Usage
Guidelines da Mojang/Microsoft e as regras de assets do Roblox.
