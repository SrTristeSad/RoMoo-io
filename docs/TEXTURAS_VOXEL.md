# Texturas e animais voxel CC0 no RoMoo-io

Arquivos de origem: [Kenney Voxel Pack](https://kenney.nl/assets/voxel-pack),
[Kenney Animal Pack Remastered](https://kenney.nl/assets/animal-pack-remastered),
e [Kenney Cube Pets](https://kenney.nl/assets/cube-pets).
Licenca CC0 (dominio publico). Credito facultativo; origem e arquivos
incluidos em `assets/voxel/kenney`. A cópia consultada veio de
`shorepine/kenney` (GitHub), que preserva os arquivos Kenney.
Nenhum arquivo oficial de Minecraft/Mojang foi copiado.

## Pastas

- `assets/voxel/kenney/tiles/`: 27 PNGs de casca/tronco, topo de tronco,
  folhagem, neve, areia, grama, cascalho, pedra, ouro, madeira, agua,
  tijolos e cactos.
- `assets/voxel/kenney/animals/boar/`: corpo, cabeca, patas e cauda
  do javali, em PNG.
- `assets/voxel/kenney/animals/fox/`: corpo, orelha, patas e cauda
  de raposa em PNG; pode servir de referencia para visual de lobo.
- `assets/voxel/kenney/animal-faces/`: imagens 2D quadradas de
  vaca, porco, bufalo, cao e urso. Sao rostos/icones e nao atlas 3D.
- `assets/voxel/kenney/models/`: modelos 3D GLB cubicos de vaca,
  porco, javali (hog), cao e urso polar, alem de
  `Textures/colormap.png` usado pela malha. O uso como outros
  animais seria adaptacao visual, nao modelo especifico de lobo/yeti.
- `LICENSE.txt`: copia das condicoes CC0 do acervo Kenney.

## Como aplicar PNGs no jogo

O Roblox **nao** pode renderizar por ID os PNGs que ficam somente no GitHub.
Primeiro, envie o PNG ao Roblox Creator Hub/Asset Manager, com acesso
autorizado para a experiencia. Copie o ID numerico que o Studio fornecer.

No `src/shared/Config.luau`, atribua os IDs em `VoxelTextureIds`.
Exemplos de mapeamento:

| Chave Config.VoxelTextureIds | Arquivo PNG |
| --- | --- |
| TrunkSide | tiles/trunk_side.png |
| TrunkTop | tiles/trunk_top.png |
| Leaves | tiles/leaves.png |
| SnowLeaves | tiles/leaves_transparent.png (ou leaves.png) |
| Stone | tiles/stone.png |
| GoldOre | tiles/stone_gold.png |
| CowFace | animal-faces/cow.png |
| PigFace | animal-faces/pig.png |
| BullFace | animal-faces/buffalo.png |
| WolfFace | animal-faces/dog.png |
| YetiFace | animal-faces/bear.png |
| BoarBody | animals/boar/boar_body.png |
| BoarHead | animals/boar/boar_head.png |
| BoarLeg | animals/boar/boar_leg.png |
| BoarTail | animals/boar/boar_tail.png |
| FoxBody | animals/fox/fox_body.png |
| FoxTail | animals/fox/fox_tail.png |

Valores `0` significam que os cubos ficam coloridos, sem downloads ou
dependencia externa. O modulo `src/server/VoxelMaterials.luau` aplica
os IDs nas faces relevantes das Parts. As texturas de terreno
`Grass/Sand/Snow/Water` estao no pacote para a futura etapa de
terreno integralmente blocado: o Terrain atual nao usa Decals.

## Como importar modelos GLB

1. Abra `RoMoo-io-Teste.rbxlx` no Roblox Studio fora de Play.
2. Extraia do ZIP `assets/voxel/kenney/models` e preserve o arquivo
   `Textures/colormap.png` para a importacao da malha.
3. Pelo 3D Importer do Studio, importe `animal-cow.glb`,
   `animal-pig.glb` e `animal-hog.glb`.
4. Crie `ServerStorage/RoMooAnimalModels` e mova os Model importados
   com nomes exatos: `Cow`, `Pig`, `Boar`.
5. Os outros modelos são opcionais: `animal-dog.glb` pode entrar como
   `Wolf` e `animal-polar.glb` como `Yeti` se voce aceitar que a
   aparencia seja diferente da especie real.
6. Salve o place. A versao `.rbxlx` compilada pelo GitHub NAO contem
   esses modelos importados ate o projeto ser salvo no Studio.
7. O programa remove scripts encontrados em modelos importados, impede
   que a geometria visual altere a colisao e conserva a hitbox do servidor.

Em `Config`, `VoxelImportedAnimalModels=true` permite os imports quando
estiverem disponiveis. Caso contrario, usa os animais cubicos procedurais.
A compilacao nao envia GLB ou PNG ao Roblox automaticamente.

## Testar

1. Execute `tests/StudioVoxelMaterialsSmokeTest.luau` na barra de
   comandos do **servidor em Play**.
2. Depois de atribuir IDs validos, veja as faces dos troncos e
   copas, rochas, ouro e animais. Confira se o PNG fica na face correta.
3. Em dois clientes, confira ataque, animacao, FPS e reproducao das
   texturas no cliente mais distante.
4. Garanta que a coleta infinita e a correnteza do rio ainda funcionam.
